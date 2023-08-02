local utf8 = require(appdf.BASE_SRC .. "app.models.utf8")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local ExternalFun = {}
ExternalFun.touchLength = 50
ExternalFun.BaseLayer = function()
	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0.5, 0.5))
	layer:setContentSize(cc.size(display.width, display.height))
	layer:setPosition(cc.p(display.cx, display.cy))
	return layer
end

function ExternalFun.exitApp()
	if freeDownloader then
		freeDownloader()
	end
	
	cc.Director:getInstance():endToLua()	
end

function ExternalFun.runActions(...) 
	return cc.runActions(...)
end
function ExternalFun.for_array_new(array, func)
    local max = #array
    if max == 0 then return end
    local _temp = {}
    local _count = 0
    for i=1,max do
        local e = array[i]
        if func(e) then
            _temp[i] = true
            _count = _count + 1
        end
    end
    if _count == 0 then return end
	local i=1
    local _index = 1
    local offset = max - _count
	while i<=max do
	    if _temp[i] ~= true then
            array[_index] = array[i]
            _index = _index+1
		end
        if i> offset then
            array[i] = nil
        end
	    i = i + 1
	end
end

function ExternalFun.for_array(array, func)
    local max = #array
    if max == 0 then return end

    local c, i = 0, 1
    while i <= max do
        local e = array[i]
        if func(e) then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
        end
        i = i + 1
    end
end

--枚举声明
function ExternalFun.declarEnum( ENSTART, ... )
	local enStart = 1;
	if nil ~= ENSTART then
		enStart = ENSTART;
	end

	local args = {...};
	local enum = {};
	for i=1,#args do
		enum[args[i]] = enStart;
		enStart = enStart + 1;
	end

	return enum;
end

--[[
MyGlobalNumber = 10
MyEnum = g_ExternalFun.enum{
"a=1",
"b",
"c=MyGlobalNumber",
"d",
"e=100",
"f",
"g=2^3",
"h",
"i=math.floor(100.001)+MyGlobalNumber*10-100/5",
"j",
}

dump(MyEnum)
print(MyEnum.a)
]]
function ExternalFun.enum(t)
	local enumtable = {}
	local enumindex = 0
	local tmp,key,val
	for _,v in ipairs(t) do
	key,val = string.gmatch(v,"([%w_]+)[%s%c]*=[%s%c]*([%w%p%s]+)%c*")()
	if key then
	tmp = "return " .. string.gsub(val,"([%w_]+)",function (x) return enumtable[x] and enumtable[x] or (type(_G[x]) == "numbers" and _G[x] or x) end)
	enumindex = loadstring(tmp)()
	else
	key = string.gsub(v,"([%w_]+)","%1");
	end
	enumtable[key] = enumindex
	enumindex = enumindex + 1
	end
	return enumtable
end
  
function ExternalFun.declarEnumWithTable( ENSTART, keyTable )
	local enStart = 1;
	if nil ~= ENSTART then
		enStart = ENSTART;
	end

	local args = keyTable;
	local enum = {};
	for i=1,#args do
		enum[args[i]] = enStart;
		enStart = enStart + 1;
	end

	return enum;
end

function ExternalFun.SAFE_RELEASE( var )
	if nil ~= var then
		var:release();
	end
end

function ExternalFun.SAFE_RETAIN( var )
	if nil ~= var then
		var:retain();
	end
end

function ExternalFun.enableBtn( btn, bEnable, bHide )
	if nil == btn then
		return
	end
	if nil == bEnable then
		bEnable = false;
	end
	if nil == bHide then
		bHide = false;
	end

	btn:setEnabled(bEnable);
	if bEnable then
		btn:setVisible(true);
		btn:setOpacity(255);
	else
		if bHide then
			btn:setVisible(false);
		else
			btn:setOpacity(125);
		end
	end
end

--无小数点 NumberThousands
function ExternalFun.numberThousands( llScore )
	return ExternalFun.formatScoreText(llScore)
end

local debug_mode = nil
--读取网络消息
function ExternalFun.read_datahelper( param )
	if debug_mode then
		print("read: " .. param.strkey .. " helper");
	end
	
	if nil ~= param.lentable then		
		local lentable = param.lentable;
		local depth = #lentable;

		if debug_mode then
			print("depth ==> ", depth);
		end
		
		local tmpT = {};
		local bigCount = 1
		for i=1,depth do
			local entryLen = lentable[i];
			if debug_mode then
				print("entryLen ==> ", entryLen);
			end
			
			local entryTable = {};
			local count = 1
			for i=1,entryLen do
				local entry = param.fun();
				if debug_mode then					
					if type(entry) == "boolean" then
						print("value ==> ", (entry and "true" or "false"))
					else
						print("value ==> ", entry);
					end
				end
				entryTable[count] = entry
				count = count + 1
			end				
			tmpT[bigCount] = entryTable	
			bigCount = bigCount + 1
		end

		return tmpT;
	else
		if debug_mode then
			local value = param.fun();
			if type(value) == "boolean" then
				print("value ==> ", (value and "true" or "false"))
			else
				print("value ==> ", value);
			end		
			return value;
		else
			return param.fun();
		end		
	end	
end

function ExternalFun.readTableHelper( param )
	local templateTable = param.dTable or {}
	local buffer = param.buffer
	local strkey = param.strkey or "default"
	local read_netdata = ExternalFun.read_netdata
	if nil ~= param.lentable then		
		local lentable = param.lentable;
		local depth = #lentable;

		if debug_mode then
			print("depth ==> ", depth);
		end
		
		local tmpT = {};
		local bigCount = 1
		

		for i=1,depth do
			local entryLen = lentable[i];
			if debug_mode then
				print("entryLen ==> ", entryLen);
			end
			
			local entryTable = {};
			local count = 1
			for i=1,entryLen do
				local entry = read_netdata(templateTable, buffer)
				if debug_mode then					
					dump(entry, strkey .. " ==> " .. i)
				end
				entryTable[count] = entry
				count = count + 1
			end					
			tmpT[bigCount] = entryTable
			bigCount = bigCount + 1
		end

		return tmpT
	else
		if debug_mode then
			local value = read_netdata(templateTable, buffer)
			dump(value,strkey )	
			return value
		else
			return read_netdata(templateTable, buffer)
		end		
	end	
end

--[[
******
* 结构体描述
* {k = "key", t = "type", s = len, l = {}}
* k 表示字段名,对应C++结构体变量名
* t 表示字段类型,对应C++结构体变量类型
* s 针对string变量特有,描述长度
* l 针对数组特有,描述数组长度,以table形式,一维数组表示为{N},N表示数组长度,多维数组表示为{N,N},N表示数组长度
* d 针对table类型,即该字段为一个table类型,d表示该字段需要读取的table数据
* ptr 针对数组,此时s必须为实际长度

** egg
* 取数据的时候,针对一维数组,假如有字段描述为 {k = "a", t = "byte", l = {3}}
* 则表示为 变量a为一个byte型数组,长度为3
* 取第一个值的方式为 a[1][1],第二个值a[1][2],依此类推

* 取数据的时候,针对二维数组,假如有字段描述为 {k = "a", t = "byte", l = {3,3}}
* 则表示为 变量a为一个byte型二维数组,长度都为3
* 则取第一个数组的第一个数据的方式为 a[1][1], 取第二个数组的第一个数据的方式为 a[2][1]
******
]]
--辅助读取int64
local int64 = Integer64.new();
int64:retain()
--读取网络消息
function ExternalFun.read_netdata( keyTable, dataBuffer )
	local cmd_table = {};
	local lower = string.lower
	local readbyte = handler(dataBuffer,dataBuffer.readbyte)
	local readint = handler(dataBuffer,dataBuffer.readint)
	local readword = handler(dataBuffer,dataBuffer.readword)
	local readdword = handler(dataBuffer,dataBuffer.readdword)
	local readscore = function() return handler(dataBuffer,dataBuffer.readscore)(int64):getvalue() end
	local readstring = handler(dataBuffer,dataBuffer.readstring)
	local readutf8 = handler(dataBuffer,dataBuffer.readutf8)
	local readbool = handler(dataBuffer,dataBuffer.readbool)
	local readdouble = handler(dataBuffer,dataBuffer.readdouble)
	local readfloat = handler(dataBuffer,dataBuffer.readfloat)
	local readshort = handler(dataBuffer,dataBuffer.readshort)
	local readTableHelper = ExternalFun.readTableHelper
	local read_datahelper = ExternalFun.read_datahelper
	for k,v in pairs(keyTable) do
		local keys = v;

		------
		--读取数据
		--类型
		local keyType = lower(keys["t"]);
		--键
		local key = keys["k"];
		--长度
		local lenT = keys["l"];
		local keyFun = nil;
		if "byte" == keyType then
			keyFun = readbyte
		elseif "int" == keyType then
			keyFun = readint
		elseif "word" == keyType then
			keyFun = readword
		elseif "dword" == keyType then
			keyFun = readdword
		elseif "score" == keyType then
			keyFun = readscore
		elseif "string" == keyType then
			if nil ~= keys["s"] then
				keyFun = function() return  readstring(keys["s"]); end
			else
				keyFun = function() return  readstring(); end
			end			
		elseif "bool" == keyType then
			keyFun = readbool
		elseif "table" == keyType then
			cmd_table[key] = readTableHelper({dTable = keys["d"], lentable = lenT, buffer = dataBuffer, strkey = key})
		elseif "double" == keyType then
			keyFun = readdouble
		elseif "float" == keyType then
			keyFun = readfloat
		elseif "short" == keyType then
			keyFun = readshort
		else
			print("read_netdata error: key ==> type==>", key, keyType);
		end
		if nil ~= keyFun then
			cmd_table[key] = read_datahelper({strkey = key, lentable = lenT, fun = keyFun});
		end
	end

	dump(cmd_table)
	return cmd_table;
end

--创建网络消息包
function ExternalFun.create_netdata( keyTable )
	local len = 0;
	local lower = string.lower
	for i=1,#keyTable do
		local keys = keyTable[i];
		local keyType = lower(keys["t"]);

		--todo 数组长度计算
		local keyLen = 0;
		if "byte" == keyType or "bool" == keyType then
			keyLen = 1;
		elseif "score" == keyType or "double" == keyType then
			keyLen = 8;
		elseif "word" == keyType or "short" == keyType then
			keyLen = 2;
		elseif "dword" == keyType or "int" == keyType or "float" == keyType then
			keyLen = 4;
		elseif "string" == keyType then
			keyLen = keys["s"];
		elseif "tchar" == keyType then
			keyLen = keys["s"] * 2
		elseif "ptr" == keyType then
			keyLen = keys["s"]
		else
			print("error keytype ==> ", keyType);
		end

		len = len + keyLen;
	end
	if debug_mode then
		print("net len ==> ", len)
	end
	return CCmd_Data:create(len);
end

function ExternalFun.read_datahelper1( param )

	-- print("read: " .. param.strkey .. " helper");

	if nil ~= param.lentable then		
		local lentable = param.lentable;
		local depth = #lentable;
		if debug_mode then
			print("depth ==> ", depth);
        	print("len1:",lentable[1]);
		end
	
		local tmpT = {};

		
		local insert = table.insert
		local function createArray(pTargetT,pLenT,pLen,pCall)

			if pLen > #pLenT then
				return ;
			end

		 	for i=1,pLenT[pLen] do
		  		if #pLenT == pLen then
					insert(pTargetT,pCall());
		  		else
		  			local t = {};
		  			insert(pTargetT,t);
		  			createArray(t,pLenT,pLen + 1,pCall)
		  		end
			end

		end

		createArray(tmpT,lentable,1,param.fun);

		return tmpT;
	else
		if debug_mode then
			local value = param.fun();
			if type(value) == "boolean" then
				print("value ==> ", (value and "true" or "false"))
			else
				print("value ==> ", value);
			end		
			return value;
		else
			return param.fun();
		end		
	end	
end
--读取网络消息
function ExternalFun.readData( keyTable, dataBuffer )
	if type(keyTable) ~= "table" then
		return {}
	end
	local cmd_table = {};
	local lower = string.lower
	local read_datahelper1 = ExternalFun.read_datahelper1
	local readbyte = handler(dataBuffer,dataBuffer.readbyte)
	local readint = handler(dataBuffer,dataBuffer.readint)
	local readword = handler(dataBuffer,dataBuffer.readword)
	local readdword = handler(dataBuffer,dataBuffer.readdword)
	local readscore = function() return handler(dataBuffer,dataBuffer.readscore)(int64):getvalue() end
	local readstring = handler(dataBuffer,dataBuffer.readstring)
	local readutf8 = handler(dataBuffer,dataBuffer.readutf8)
	local readbool = handler(dataBuffer,dataBuffer.readbool)
	local readdouble = handler(dataBuffer,dataBuffer.readdouble)
	local readfloat = handler(dataBuffer,dataBuffer.readfloat)
	local readshort = handler(dataBuffer,dataBuffer.readshort)
	local readData = ExternalFun.readData
	for k,v in pairs(keyTable) do
		local keys = v;

		------
		--读取数据
		--类型
		local keyType = lower(keys["t"]);
		--键
		local key = keys["k"];
		--长度
		local lenT = keys["l"];
		local keyFun = nil;
		
		-- vector类型先求出size
		if "table" == keyType then
			lenT = cmd_table[keyTable[k-1].k]
			lenT = {lenT};
		end
		
		
		if "byte" == keyType then
			keyFun = readbyte
		elseif "int" == keyType then
			keyFun = readint
		elseif "word" == keyType then
			keyFun = readword
		elseif "dword" == keyType then
			keyFun = readdword
		elseif "score" == keyType then
			keyFun = readscore
		elseif "tchar" == keyType then
			if nil ~= keys["s"] then
				keyFun =  function() return  readstring(keys["s"]); end
			elseif keys.ss then  --需要自己先读取大小的
				keyFun = function()
					local __strLen = readint
					if __strLen == 0 then
						return "";
					end
					return readstring(__strLen);
				end
			else
				keyFun = function() return  readstring(); end
			end
		elseif "char" == keyType then
			if keys.ss then
				keyFun = function()
					local __strLen = readword
					if __strLen == 0 then
						return "";
					end
					return readutf8(__strLen);
				end
			elseif keys.s then
				if keys.s == 0 then
					keyFun = function() 
						local ss =   readutf8(); 
						return  ss; 
					end
				else
					keyFun = function() 
						local ss = readutf8(keys.s); 
						return  ss; 
					end
				end
			end
		elseif "bool" == keyType then
			keyFun = readbool
		elseif "table" == keyType then
			keyFun = function()
				return readData(keys["d"],dataBuffer)
			end
		elseif "double" == keyType then
			keyFun = readdouble
		elseif "float" == keyType then
			keyFun = readfloat
		elseif "short" == keyType then
			keyFun = readshort
		elseif "selfdefine" == keyType	then	
			keyFun = function() return keys.func(dataBuffer,cmd_table) end;
		else
			print("readData error: key ==> type==>", key, keyType);
			-- error("readData error: key ==> type==>", key, keyType)
		end
		if nil ~= keyFun then
			cmd_table[key] = read_datahelper1({strkey = key, lentable = lenT, fun = keyFun});
		end
	end
	return cmd_table;
end


function ExternalFun.writeData(p_mainid,p_subid,keyTable,p_data)
	if type(keyTable) ~= "table" then
		print("create auto len")
		return CCmd_Data:create()
	end
	-- dump(p_data)
	local lower = string.lower
	local len = 0;
	for i=1,#keyTable do
		local keys = keyTable[i];
		local keyType = lower(keys["t"]);
		local __lenth  = keys['l'];
		__lenth = __lenth and __lenth[1];
		__lenth = __lenth or 1;

		if keyType == "vector" then
			len = len + 4;     -- vector 额外加一个int的长度
			__lenth = #p_data[keys["k"]];
			keyType = keys["realType"];
		end

		--todo 数组长度计算
		local keyLen = 0;
		if "byte" == keyType or "bool" == keyType then
			keyLen = 1;
		elseif "score" == keyType or "double" == keyType then
			keyLen = 8;
		elseif "word" == keyType or "short" == keyType then
			keyLen = 2;
		elseif "dword" == keyType or "int" == keyType or "float" == keyType then
			keyLen = 4;
		elseif "string" == keyType then
			keyLen = keys["s"];
		elseif "tchar" == keyType then
			keyLen = keys["s"] * 2
		elseif "ptr" == keyType then
			keyLen = keys["s"]
		elseif "selfdefine" == keyType then
			keyLen = keys.funcLen(p_data);
		else
			print("error keytype ==> ", keyType);
		end

		keyLen = keyLen * __lenth;
		keys['___lenth'] = keyLen;
		if debug_mode then
			print(keys["k"],"len ==> ", keyLen)
		end
		len = len + keyLen;
	end
	if debug_mode then
		print("net len ==> ", len)
	end

	local __cmdData =  CCmd_Data:create(len);
	__cmdData:setcmdinfo(p_mainid,p_subid);

	for i=1,#keyTable do

		local keys = keyTable[i];
		local keyType = lower(keys["t"]);
		local __lenth  = keys['l'];
		__lenth = __lenth and __lenth[1];
		__lenth = __lenth or 1;

		local __value = p_data[keys['k']];

		if keyType == "vector" then
			__lenth = #p_data[keys["k"]];
			__cmdData:pushint(__lenth);
			keyType = keys["realType"];
			if __lenth == 1 then 
				__value = __value[1];
			end
		end

		if __value == nil then
			print("__private.writeData no value ==> ", keys['k']);
		end

		local baseWriteFunc = nil;

		if "bool" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushbool(pValue);
			end
		elseif "byte" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushbyte(pValue);
			end
		elseif "word" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushword(pValue);
			end
			
		elseif "short" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushshort(pValue);
			end
			
		elseif "int" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushint(pValue);
			end
			
		elseif "dword" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushdword(pValue);
			end
			
		elseif "float" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushfloat(pValue);
			end
			
		elseif "double" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushdouble(pValue);	
			end
			
		elseif "score" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushscore(pValue);	
			end
				
		elseif "string" == keyType then
			local gbk_flag = keys['gbk_flag'] or 0;
			baseWriteFunc = function(pValue)
				__cmdData:pushstring(pValue,keys['s'],gbk_flag);
			end
			
		elseif "tchar" == keyType then
			baseWriteFunc = function(pValue)
				__cmdData:pushstring(pValue,keys['s']);			
			end
		elseif "selfdefine" == keyType then	
			baseWriteFunc = function(pValue)
				return keys.funcWrite(__cmdData,p_data);		
			end					
		else
			print("__private.writeData error keytype ==> ", keyType,keys['k']);
		end

		if baseWriteFunc then
			if __lenth == 1 then
				baseWriteFunc(__value);
			else
				local __currentLenth = __cmdData:getcurlen();
				for i=1,__lenth do
					if __value[i] then
						baseWriteFunc(__value[i]);
					else
						baseWriteFunc(0);
					end
				end
				-- __cmdData:setlen(__currentLenth + keys.___lenth);
			end
		end

	end

	return __cmdData;
end


--导入包
function ExternalFun.req_var( module_name )
	if (nil ~= module_name) and ("string" == type(module_name)) then
		return require(module_name);
	end
end

--加载界面根节点，设置缩放达到适配
function ExternalFun.loadRootCSB( csbFile, parent, isOffset)
	local rootlayer = ccui.Layout:create()
    if ylAll.WIDTH == 1334 and ylAll.HEIGHT == 750 then
 		rootlayer:setContentSize(1334,750) 
		rootlayer:setScale(ylAll.WIDTH / 1334) 
    end
	if nil ~= parent and false ~= parent then
		parent:addChild(rootlayer);
	end
	local csbnode = cc.CSLoader:createNode(csbFile);
	rootlayer:addChild(csbnode);
    if isOffset ~= false then
        csbnode:setPositionX(g_offsetX)
    end
	return rootlayer, csbnode;
end

--加载csb资源
function ExternalFun.loadCSB( csbFile, parent ,isOffset)
	print("loadCSB csbFile = ", csbFile)
	local csbnode = cc.CSLoader:createNode(csbFile);
	if nil ~= parent then
		parent:addChild(csbnode);
	end
    if isOffset ~= false then
        csbnode:setPositionX(g_offsetX)
    end
	return csbnode;	
end

function ExternalFun.adapterWidescreen(csbNode)
	if csbNode then
        csbNode:setAnchorPoint(0,0)
        csbNode:setScale(1.44)
        csbNode:setPositionX(g_offsetX)
    end
end

--加载 帧动画
function ExternalFun.loadTimeLine( csbFile )
	-- print("loadTimeLine csbFile = ",csbFile)
	return cc.CSLoader:createTimeline(csbFile);	 
end
function ExternalFun.loadChildrenHandler(self,rootNode)
	local function getChildHandler(p_node)
		local __children = p_node:getChildren();

        if type(__children) ~= 'table' then
            return
        else
            if table.nums(__children) == 0 then
                return
            end
        end

		for k,v in pairs(__children) do
			local __name = v:getName();
			if v.setFontName then
				-- v:setFontName("base/res/fonts/arial.ttf");
			end
            if v.setTitleFontName then
                -- v:setTitleFontName("base/res/fonts/arial.ttf");
            end
		    self['mm_'..__name] = v;
			getChildHandler(v);
		end
	end
	getChildHandler(rootNode);
end

--挂载脚本到子节点中去
function ExternalFun.addScriptForChildNode(node,ScriptFileFath,...)
    if not ScriptFileFath or #ScriptFileFath == 0 then return end;

    ExternalFun.loadChildrenHandler(node,node);
    local ScripData = {};
    setmetatableindex(ScripData, require(ScriptFileFath))

    if not ScripData.ctor then
        -- add default constructor
        ScripData.ctor = function() end
    end

    for k,v in pairs(ScripData.__index) do
        node[k]=v;
    end
    node:ctor(...);
    return node;
end


--注册node事件
function ExternalFun.registerNodeEvent( node )
	if nil == node then
		return
	end
	local function onNodeEvent( event )
		if event == "enter" and nil ~= node.onEnter then
			node:onEnter()
		elseif event == "enterTransitionFinish" 
			and nil ~= node.onEnterTransitionFinish then
			node:onEnterTransitionFinish()
		elseif event == "exitTransitionStart" 
			and nil ~= node.onExitTransitionStart then
			node:onExitTransitionStart()
		elseif event == "exit" and nil ~= node.onExit then
			node:onExit()
		elseif event == "cleanup" and nil ~= node.onCleanup then
			node:onCleanup()
		end
	end

	node:registerScriptHandler(onNodeEvent)
end

--注册touch事件
function ExternalFun.registerTouchEvent( node, bSwallow )
	if nil == node then
		return false
	end
	local function onNodeEvent( event )
		if event == "enter" and nil ~= node.onEnter then
			node:onEnter()
		elseif event == "enterTransitionFinish" then
			--注册触摸
			local function onTouchBegan( touch, event )
				if nil == node.onTouchBegan then
					return false
				end
				return node:onTouchBegan(touch, event)
			end

			local function onTouchMoved(touch, event)
				if nil ~= node.onTouchMoved then
					node:onTouchMoved(touch, event)
				end
			end

			local function onTouchEnded( touch, event )
				if nil ~= node.onTouchEnded then
					node:onTouchEnded(touch, event)
				end       
			end

			local listener = cc.EventListenerTouchOneByOne:create()
			bSwallow = bSwallow or false
			listener:setSwallowTouches(bSwallow)
			node._listener = listener
		    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
		    local eventDispatcher = node:getEventDispatcher()
		    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

			if nil ~= node.onEnterTransitionFinish then
				node:onEnterTransitionFinish()
			end
		elseif event == "exitTransitionStart" 
			and nil ~= node.onExitTransitionStart then
			node:onExitTransitionStart()
		elseif event == "exit" and nil ~= node.onExit then	
			if nil ~= node._listener then
				local eventDispatcher = node:getEventDispatcher()
				eventDispatcher:removeEventListener(node._listener)
			end			

			if nil ~= node.onExit then
				node:onExit()
			end
		elseif event == "cleanup" and nil ~= node.onCleanup then
			node:onCleanup()
		end
	end
	node:registerScriptHandler(onNodeEvent)
	return true
end

filterLexicon = {}
--加载屏蔽词库
function ExternalFun.loadLexicon( )
	local startTime = os.clock()
	local str = cc.FileUtils:getInstance():getStringFromFile("badwords.txt")

	local fuc = loadstring(str)
	
	if nil ~= fuc and type(fuc) == "function" then
		filterLexicon = fuc()
	end
    filterLexicon = filterLexicon or {}
	local endTime = os.clock()
	print("load time ==> " .. endTime - startTime)
end
ExternalFun.loadLexicon()

--判断是否包含过滤词
function ExternalFun.isContainBadWords( str )
	local startTime = os.clock()

	print("origin ==> " .. str)
	--特殊字符过滤
	str = string.gsub(str, "[%w '|/?·`,;.~!@#$%^&*()-_。，、+]", "")
	print("gsub ==> " .. str)
	--是否直接为敏感字符
	local res = filterLexicon[str]
	--是否包含
	for k,v in pairs(filterLexicon)	do
		local b,e = string.find(str, k)
		if nil ~= b or nil ~= e then
			res = true
			break
		end
	end

	local endTime = os.clock()
	print("excute time ==> " .. endTime - startTime)

	return res ~= nil
end

--utf8字符串分割为单个字符
function ExternalFun.utf8StringSplit( str )
	local strTable = {}
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
		strTable[#strTable+1] = uchar
	end
	return strTable
end

function ExternalFun.replaceAll(src, regex, replacement)
	return string.gsub(src, regex, replacement)
end

function ExternalFun.cleanZero(s)
	-- 如果传入的是空串则继续返回空串
    if"" == s then    
        return ""
    end

    -- 字符串中存在多个'零'在一起的时候只读出一个'零'，并省略多余的单位
    
    local regex1 = {"零仟", "零佰", "零拾"}
    local regex2 = {"零亿", "零万", "零元"}
    local regex3 = {"亿", "万", "元"}
    local regex4 = {"零角", "零分"}
    
    -- 第一轮转换把 "零仟", 零佰","零拾"等字符串替换成一个"零"
    for i = 1, 3 do    
        s = ExternalFun.replaceAll(s, regex1[i], "零")
    end

    -- 第二轮转换考虑 "零亿","零万","零元"等情况
    -- "亿","万","元"这些单位有些情况是不能省的，需要保留下来
    for i = 1, 3 do
        -- 当第一轮转换过后有可能有很多个零叠在一起
        -- 要把很多个重复的零变成一个零
        s = ExternalFun.replaceAll(s, "零零零", "零")
        s = ExternalFun.replaceAll(s, "零零", "零")
        s = ExternalFun.replaceAll(s, regex2[i], regex3[i])
    end

    -- 第三轮转换把"零角","零分"字符串省略
    for i = 1, 2 do
        s = ExternalFun.replaceAll(s, regex4[i], "")
    end

    -- 当"万"到"亿"之间全部是"零"的时候，忽略"亿万"单位，只保留一个"亿"
    s = ExternalFun.replaceAll(s, "亿万", "亿")
    
    --去掉单位
    s = ExternalFun.replaceAll(s, "元", "")
    return s
end

--人民币阿拉伯数字转大写
function ExternalFun.numberTransiform(strCount)
	local big_num = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"}
	local big_mt = {__index = function() return "" end }
	setmetatable(big_num,big_mt)
	local unit = {"元", "拾", "佰", "仟", "万",
                  --拾万位到千万位
                  "拾", "佰", "仟",
                  --亿万位到万亿位
                  "亿", "拾", "佰", "仟", "万",}
    local unit_mt = {__index = function() return "" end }
    setmetatable(unit,unit_mt)
    local tmp_str = ""
    local len = string.len(strCount)
    for i = 1, len do
    	tmp_str = tmp_str .. big_num[string.byte(strCount, i) - 47] .. unit[len - i + 1]
    end
    return ExternalFun.cleanZero(tmp_str)
end

--播放音效 (根据性别不同播放不同的音效)
function ExternalFun.playSoundEffect( path, useritem )
	local sound_path = path
	if nil == useritem then
		sound_path = "sound_res/" .. path
	else
		-- 0:女/1:男
		local gender = useritem.cbGender
		sound_path = string.format("sound_res/%d/%s", gender,path)
	end
	if GlobalUserItem.bSoundAble then
		return AudioEngine.playEffect(sound_path,false)
	end	
end

function ExternalFun.playEffect(eff,isLoop)
	if GlobalUserItem.bSoundAble then
		AudioEngine.playEffect(eff,isLoop)
	end
end

function ExternalFun.stopEffect(handle)
	AudioEngine.stopEffect(handle)
end

function ExternalFun.stopMusic()
	AudioEngine.stopMusic()
end

function ExternalFun.pauseMusic()
	AudioEngine.pauseMusic()
end

function ExternalFun.resumeMusic()
	AudioEngine.resumeMusic()
end



function ExternalFun.stopAllEffects()
	AudioEngine.stopAllEffects()
end

function ExternalFun.playMusic(eff, loop)
	if not eff then
		eff = ExternalFun.music_file
	end
	if loop == nil then
		loop = true
	end
	
	ExternalFun.music_file = eff
	if GlobalUserItem.bVoiceAble then
		AudioEngine.playMusic(eff, loop)
	end
end

function ExternalFun.playClickEffect( )
	if GlobalUserItem.bSoundAble then
		AudioEngine.playEffect(cc.FileUtils:getInstance():fullPathForFilename("dating/music/click.mp3"),false)
	end
end

--播放背景音乐
function ExternalFun.playBackgroudAudio( bgfile )
	local strfile = bgfile
	if nil == bgfile then
		strfile = "backgroud01.mp3"
	end
	strfile = "sound_res/" .. strfile

	ExternalFun.playMusic(strfile, true)
end

--播放大厅背景音乐
function ExternalFun.playPlazzBackgroudAudio( )
	ExternalFun.stopMusic()
	ExternalFun.playMusic("sound/backgroud01.mp3", true)
end

function ExternalFun.checkLen(str, min, max, name)
	if str == nil or str == "" then
		-- showToast(nil,string.format('%s必须为%d~%d个字符,请重新输入', name, min, max),2,ylAll.MsgColorRed)
		return false
	end
	local len = ef.stringLen(str)
	if len < min or len > max then
		-- showToast(nil,string.format('%s必须为%d~%d个字符,请重新输入', name, min, max),2,ylAll.MsgColorRed)
		return false
	end
	return true
end

--中文长度计算(同步pc,中文长度为2)
function ExternalFun.stringLen(szText)
	local len = 0
	local i = 1
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			i = i + 3
			len = len + 2
		else
			i = i + 1
			len = len + 1
		end
	end
	return len
end

--webview 可见设置(已知在4s设备上设置可见会引发bug)
function ExternalFun.visibleWebView(webview, visible)
	if nil == webview then
		return
	end

	local target = cc.Application:getInstance():getTargetPlatform()
	if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
		local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
		local con = math.max(size.width, size.height)
		if con ~= 960 then
	        webview:setVisible(visible)
	        return true
	    end
	else
		webview:setVisible(visible)
		return true
	end	
	return false
end

-- 过滤emoji表情
-- 编码为 226 的emoji字符,不确定是否是某个中文字符
-- [%z\48-\57\64-\126\226-\233][\128-\191] 正则匹配式去除了226
function ExternalFun.filterEmoji(str)
	local newstr = ""
	print(string.byte(str))
	for unchar in string.gfind(str, "[%z\25-\57\64-\126\227-\240][\128-\191]*") do
		newstr = newstr .. unchar
	end
	print(newstr)
	return newstr
end

-- 判断是否包含emoji
-- 编码为 226 的emoji字符,不确定是否是某个中文字符
function ExternalFun.isContainEmoji(str)
	if nil ~= containEmoji then
		return containEmoji(str)
	end
	local origincount = string.utf8len(str)
	print("origin " .. origincount)
	local count = 0
	for unchar in string.gfind(str, "[%z\25-\57\64-\126\227-\240][\128-\191]*") do
		--[[print(string.len(unchar))
		print(string.byte(unchar))]]
		if string.len(unchar) < 4 then
			count = count + 1
		end		
	end
	print("newcount " .. count)
	return count ~= origincount
end

local TouchFilter = class("TouchFilter", function(showTime, autohide, msg)
		return display.newLayer(cc.c4b(0, 0, 0, 0))
	end)
function TouchFilter:ctor(showTime, autohide, msg)
	ExternalFun.registerTouchEvent(self, true)
	showTime = showTime or 2
	self.m_msgTime = showTime
	if autohide then			
		self:runAction(cc.Sequence:create(cc.DelayTime:create(showTime), cc.RemoveSelf:create(true)))
	end	
	self.m_filterMsg = msg
end

function TouchFilter:onTouchBegan(touch, event)
	return self:isVisible()
end

function TouchFilter:onTouchEnded(touch, event)
	print("TouchFilter:onTouchEnded")
	if type(self.m_filterMsg) == "string" and "" ~= self.m_filterMsg then
		showToast(self.m_filterMsg, self.m_msgTime)
	end
end

local TOUCH_FILTER_NAME = "__touch_filter_node_name__"
--触摸过滤
function ExternalFun.popupTouchFilter( showTime, autohide, msg, parent )
	--[[local filter = TouchFilter:create(showTime, autohide, msg)
	local runScene = parent or cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
		local lastfilter = runScene:getChildByName(TOUCH_FILTER_NAME)
		if nil ~= lastfilter then
			lastfilter:stopAllActions()
			lastfilter:removeFromParent()
		end
		if nil ~= filter then
			filter:setName(TOUCH_FILTER_NAME)
			runScene:addChild(filter, -1)
		end
	end]]
end

function ExternalFun.dismissTouchFilter()
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
		local filter = runScene:getChildByName(TOUCH_FILTER_NAME)
		if nil ~= filter then
			filter:stopAllActions()
			filter:removeFromParent()
		end
	end
end

function ExternalFun.formatScoreInt(score)
	return ExternalFun.formatScoreText(score, '%d')
end

function ExternalFun.formatScore( score, fmt )
	return ExternalFun.formatScoreText(score, fmt)
end

local function format(score, fmt)
	fmt = fmt or '%.2f'
	score = tonumber(score)
	local scorestr = score
	if score < 10000 then
		return scorestr
	end

	if score < 100000000 then
		scorestr = string.format(fmt .. "万", score / 10000)
		return scorestr
	end
	scorestr = string.format(fmt .. "亿", score / 100000000)
	return scorestr
end

-- eg: 10000 转 1.0万
function ExternalFun.formatScoreText1(score)

if score == 0 or score == nil then
    return "0"
end
	local scorestr = ExternalFun.formatScore(score)
	if score < 10000 then
		return scorestr
	end

	if score < 100000000 then
        local tmp =  math.fmod(score,10000)
        if tmp>0 then
		    scorestr = string.format("%.2f万", score / 10000)
        else
            scorestr = string.format("%.0f万", score / 10000)
        end
		return scorestr
	end
    --	scorestr = string.format("%.2f万", score / 10000)
	scorestr = string.format("%.1f亿", score / 100000000)
	return scorestr
end
-- eg: 10000 转 1.0万
function ExternalFun.formatScoreText(score, fmt)
	if score >= 0 then
		return format(score, fmt)
	else
		return "-" ..format(-score, fmt)
	end
end

function ExternalFun.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function ExternalFun.formatName(str, maxLen)
	maxLen = maxLen or 7

	local u8Len = utf8.len(str)
	if u8Len <= maxLen then
		return str
	end

    local should_cut = false
    local last_is_ascii = true
	local n = 0
	for i, c in utf8.chars(str) do
		if string.byte(c) > 128 then
			n = n + 1
            last_is_ascii = false
		else
			n = n + 0.5
            last_is_ascii = true
		end
        
		if n >= maxLen then
            if last_is_ascii then
                n = i - 3
            else
                n = i - 1
            end
            should_cut = true
			break
		end
	end
    
    if should_cut then
        str = utf8.sub(str, 1, n) .. "..."
    elseif n > maxLen then
        str = utf8.sub(str, 1, maxLen-2) .. "..."
    end
    return str
end
function ExternalFun.GetNumber(str)
	for s in string.gmatch(str, "%-?%d+%.?%d?") do 
		local i, j = string.find(str, s)
		if j>0 and j+1 < string.len(str)  then
			str = string.sub(str, j+1)
		else
			str =""
		end
		return s*1, str
	end
	return 0, ""
end
-- 随机ip地址
local external_ip_long = 
{
	{ 607649792, 608174079 }, -- 36.56.0.0-36.63.255.255
    { 1038614528, 1039007743 }, -- 61.232.0.0-61.237.255.255
    { 1783627776, 1784676351 }, -- 106.80.0.0-106.95.255.255
    { 2035023872, 2035154943 }, -- 121.76.0.0-121.77.255.255
    { 2078801920, 2079064063 }, -- 123.232.0.0-123.235.255.255
    { -1950089216, -1948778497 }, -- 139.196.0.0-139.215.255.255
    { -1425539072, -1425014785 }, -- 171.8.0.0-171.15.255.255
    { -1236271104, -1235419137 }, -- 182.80.0.0-182.92.255.255
    { -770113536, -768606209 }, -- 210.25.0.0-210.47.255.255
    { -569376768, -564133889 }, -- 222.16.0.0-222.95.255.255
}
function ExternalFun.random_longip()
	local rand_key = math.random(1, 10)
	local bengin_long = external_ip_long[rand_key][1] or 0
	local end_long = external_ip_long[rand_key][2] or 0
	return math.random(bengin_long, end_long)
end

function ExternalFun.long2ip( value )
	if not value then
		return {p=0,m=0,s=0,b=0}
	end
	if nil == bit then
		print("not support bit module")
		return {p=0,m=0,s=0,b=0}
	end
	local tmp 
	if type(value) ~= "number" then
		tmp = tonumber(value)
	else
		tmp = value
	end
	return
	{
		p = bit.rshift(bit.band(tmp,0xFF000000),24),
		m = bit.rshift(bit.band(tmp,0x00FF0000),16),
		s = bit.rshift(bit.band(tmp,0x0000FF00),8),
		b = bit.band(tmp,0x000000FF)
	}
end

-- 下标组合
local tabCombinations = {}
-- param[num] 
-- param[need] 
function ExternalFun.idx_combine( num, need, bSort )
	if type(num) ~= "number" or type(need) ~= "number" then
		print("param invalid")
		return {}
	end
	bSort = bSort or false
	local key = string.format("%d_combine_%d_bsort_%s", num, need, tostring(bSort))
	if nil ~= tabCombinations[key] then
		return tabCombinations[key]
	end

	-- 排序下标
	local key_idx = {}
	if bSort then
		for i = 1, num do
			key_idx[i] = num - i + 1
		end
	end
	local combs = {}
    local comb = {}
    local function _combine( m, k )
    	for i = m, k, -1 do
    		comb[k] = i
    		if k > 1 then
    			_combine(i - 1, k - 1)
    		else
    			local tmp = {}
    			if bSort then
    				for k, v in pairs(comb) do
	    				table.insert(tmp, 1, key_idx[v])
	    			end
    			else
    				tmp = clone(comb)
    			end
    			table.insert(combs, tmp)
    		end
    	end
    end
    _combine( num, need )

    if 0 ~= #combs then
    	tabCombinations[key] = combs
    end
    return combs
end

function showToast1(context, msg, delaytime, color)
	if msg ~= nil then
		return ExternalFun.tip(msg, delaytime, color)
	else
		return ExternalFun.tip(context, msg, delaytime)
	end
end
-- showToast
function ExternalFun.tip(msg, delaytime, color)
	-- showToast(nil,msg, delaytime, color)
end


--------------------------------------------------------
local function parseColor(color)
	local r = tonumber(color:sub(1,2),16)
	local g = tonumber(color:sub(3,4),16)
	local b = tonumber(color:sub(5,6),16)
	return r,g,b
end

local function doParse(code, ret)
    
    do
        local n, pos, color = code:find('^|c(%x%x%x%x%x%x?)')

        if n then
            ret.set()
            ret.color = color
            return code:sub(pos+1)
        end
    end

    do 
        local n, pos, stop = code:find("^|r")

        if n then
            ret.set()
            return code:sub(pos+1)
        end
    end

    do 
        local n, pos, stop = code:find('|')

        if n then
            ret.string = ret.string..code:sub(0, pos-1)

            return code:sub(pos)
        else
            ret.string = code;

            return nil
        end
    end

    return nil
end

function ExternalFun.setRichText(label, str, size, font)
    local ret = {label = label, string = "", font=font or "", size=size or 20}
    
    ret.set = function()
        if #ret.string == 0 then return end

        local c4 = nil;
        if ret.color == nil then 
            local cd = label:getColor();
            c4 = cc.c3b(cd.r,cd.g,cd.b);
        else
            local r,g,b = parseColor(ret.color);
            c4 = cc.c3b(r,g,b);
        end
        ret.label:pushBackElement(ccui.RichElementText:create(0, c4, 255, ret.string, ret.font, ret.size))
        ret.string = ""
        ret.color=nil
    end

    while true do
        str = doParse(str, ret)

        if not str or #str == 0 then
            break
        end
    end

    ret.set()
end

function ExternalFun.DelayCallFunc(node, delayTime, func, params)
	local delay = cc.DelayTime:create(delayTime)
	local callFunc = cc.CallFunc:create(function()
		func(params)
	end)
	node:runAction(cc.Sequence:create(delay, callFunc))
end

function ExternalFun.RegisterNode(rootNode, node)
    local function Register(root)
        if root:getChildrenCount() > 0 then
            local children = root:getChildren()
            for key, child in pairs (children) do
                Register(child)
            end
        end
        rootNode[root:getName()] = root
    end

    Register(node)
end

function ExternalFun.scheduleLabel(label, from, to, totalTime)
	local time = 0
	totalTime = totalTime or 1

	local function run(dt)
		time = time + dt
		local value = from + (to - from) * math.min(1, time / totalTime)
		label:setString(math.floor(value))
		if time >= totalTime then
			label:unscheduleUpdate()
		end
	end

	label:unscheduleUpdate()
    label:scheduleUpdate(run)
end

function ExternalFun.http_get(info)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:open("GET", info.url)
	xhr:setRequestHeader("Content-type", "application/json");
	xhr:registerScriptHandler(function()
		local ok, str, err
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   		ok, str = true, xhr.response
	    else
	    	err = "http fail readyState:"..xhr.readyState.."#status:"..xhr.status
	    end

	   	if info.callback then 
	   		if ok then
		    	info.callback(true, str)
		    else
		    	print(err)
		    	info.callback(false, err)
		    end
	    end	    
	end)
	xhr:send()
end

function ExternalFun.http_get_json(info)
	local cb = info.callback
	info.callback = function(ok, str)
		if ok then
			local err
            release_print("http_get_json_str:"..str)
	   		local ok, jsondata = xpcall(function() return cjson.decode(str) end, function(e) err = e end)
	   		if ok then
				cb(true, jsondata)
			else
				cb(false, err)
	   		end
		else
			cb(false, str)
		end
	end
	return ExternalFun.http_get(info)
end

function ExternalFun.onHttpJsionTable(url,methon,params,callback)
	local xhr = cc.XMLHttpRequest:new() --创建请求
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON--返回数据类型为json
	local bPost = ((methon == "POST") or (methon == "post"))
	--模式判断
	if not bPost then
		if params ~= nil and params ~= "" then
			xhr:open(methon, url.."?"..params)
		else
			xhr:open(methon, url)
		end
	else
		xhr:setRequestHeader("Content-Type", "application/json")
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
					-- print("onHttpJsionTable_cjson_error")
					datatable = "System error:Response decode error!"--nil
				end
			end
		else
			datatable = "System error:Http state error! ("..xhr.readyState.."-"..xhr.status..")"
			-- print("onJsionTable http fail readyState:"..xhr.readyState.."#status:"..xhr.status)
		end
		if type(callback) == "function" then      
			callback(ok,datatable)         --pcall在保护模式（protected mode）下执行函数内容，同时捕获所有的异常和错误。若一切正常，pcall返回true以及“被执行函数”的返回值；否则返回nil和错误信息。
		end        
	end
	xhr:registerScriptHandler(onJsionTable) --注册响应函数
	if not bPost then
		xhr:send(15) --发送请求
	else
		xhr:send(params,15)
	end
	return true
end

--获取固定长度的字符串
--返回被截取的字符串及是否有剩余字符串
function ExternalFun.GetFixLenOfString(instr, length, fontname, fontsize)
    if instr == '' or length <= 0 then
        return instr,true
    end

    local labelLen =cc.LabelTTF:create(instr, fontname, fontsize):getContentSize().width
    if labelLen <= length then
        return instr,true
    end

    --判断字符结尾是不是中文，返回结尾有几个字符属于中文
    local function judgeLastIsChinese(strFirst, strSecond)
        local offset = 0
        local dropping = string.byte(strFirst, string.len(strFirst)) 
        local dropping2 = string.byte(strSecond, 1)
        if dropping then
            if dropping>=128 and dropping<192 then--汉字
                if dropping2 and  dropping2>=128 and dropping2<192 then
                    offset = 2
                end
            else
                if dropping2 and  dropping2>=128 and dropping2<192 then
                    offset = 1
                end
            end
        end
        return offset
    end

    local strLen = string.len(instr)
    local firstStr = string.sub(instr, 1, math.floor(strLen/2))
    local secondStr = string.sub(instr, math.floor(strLen/2) + 1)
    --判定结尾是不是中文
    local lastIsChina = false
    local offset = judgeLastIsChinese(firstStr, secondStr)
    if offset and offset > 0 then
        secondStr = string.sub(firstStr, string.len(firstStr)-offset+1)..secondStr
        firstStr = string.sub(firstStr, 1, string.len(firstStr)-offset)     
        lastIsChina = true 
    else    
        lastIsChina = false    
    end
    local leftLen = length
    local outStr = '' 

    while(labelLen ~= leftLen and secondStr and secondStr ~= '') do
        labelLen = CCLabelTTF:create(firstStr, fontname, fontsize):getContentSize().width
        --长度不够就在后面字符串再取一半
        if labelLen < leftLen then     
            --将已经取到的字符保存
            leftLen = leftLen - labelLen
            outStr = outStr..firstStr
            --接着取剩下的字符
            strLen = string.len(secondStr)
            --只剩不到一个字符
            if strLen <=1 or (lastIsChina and strLen <= 3) then
                firstStr = secondStr
                break
            end
            firstStr = string.sub(secondStr, 1, math.floor(strLen/2))
            secondStr = string.sub(secondStr, math.floor(strLen/2) + 1)
            --判定结尾是不是中文
            local offset = judgeLastIsChinese(firstStr, secondStr)
            if offset and offset > 0 then
                secondStr = string.sub(firstStr, string.len(firstStr)-offset+1)..secondStr
                firstStr = string.sub(firstStr, 1, string.len(firstStr)-offset) 
                if firstStr == '' then
                    break
                end  
                lastIsChina = true  
            else
                lastIsChina = false       
            end
        elseif labelLen > leftLen then--太长了就自身取一半
            strLen = string.len(firstStr)
            secondStr = string.sub(firstStr, math.floor(strLen/2) + 1)
            firstStr = string.sub(firstStr, 1, math.floor(strLen/2))
            --判定结尾是不是中文
            local offset = judgeLastIsChinese(firstStr, secondStr)
            if offset and offset > 0 then
                secondStr = string.sub(firstStr, string.len(firstStr)-offset+1)..secondStr
                firstStr = string.sub(firstStr, 1, string.len(firstStr)-offset)     
                lastIsChina = true 
            else    
                lastIsChina = false    
            end
        end
    end--for while

    outStr = outStr..firstStr
    --去掉最后一个中文，防止乱码
    outStr = string.sub(outStr, 1, string.len(outStr)-judgeLastIsChinese(outStr, string.sub(instr, string.len(outStr)+1)))
    
    return outStr,false
end


--将字符串转换为固定长度的多行字符
--返回带换行的字符串及行数
function ExternalFun.FormatString2FixLen(instr, length, fontname, fontsize)
    local resultStr = ''    --返回的字符串
    local lineCount = 0
    local str_vec = {}      --创建一个字符串类型的顺序容器

    local strOut,bFinish = ExternalFun.GetFixLenOfString(instr, length, fontname, fontsize)
    local leftStr = string.sub(instr, string.len(strOut) + 1, string.len(instr))
    while not bFinish  do            
        table.insert(str_vec, strOut)
        strOut,bFinish = ExternalFun.GetFixLenOfString(leftStr, length, fontname, fontsize)
        leftStr = string.sub(leftStr, string.len(strOut) + 1, string.len(leftStr))
    end  
    --将最后一个字符串放入数组
    table.insert(str_vec, strOut)
    for index = 1,#str_vec do   
        resultStr = resultStr..str_vec[index].."\n" 
    end  
    resultStr = string.sub(resultStr,0,string.len(resultStr)-1)
    return str_vec[1], #str_vec
end

function ExternalFun.FormatString2FixLenNew(instr, length, fontname, fontsize)
    local resultStr = ''    --返回的字符串
    local lineCount = 0
    local str_vec = {}      --创建一个字符串类型的顺序容器

    local strOut,bFinish = ExternalFun.GetFixLenOfString(instr, length, fontname, fontsize)
    local leftStr = string.sub(instr, string.len(strOut) + 1, string.len(instr))
    while not bFinish  do            
        table.insert(str_vec, strOut)
        strOut,bFinish = ExternalFun.GetFixLenOfString(leftStr, length, fontname, fontsize)
        leftStr = string.sub(leftStr, string.len(strOut) + 1, string.len(leftStr))
    end  
    --将最后一个字符串放入数组
    table.insert(str_vec, strOut)
    for index = 1,#str_vec do   
        resultStr = resultStr..str_vec[index].."\n" 
    end  
    resultStr = string.sub(resultStr,0,string.len(resultStr)-1)
    return str_vec, #str_vec
end
--简单字符串转tab
function ExternalFun.String2Tab(str)
   local len = string.len(str)
   local srcTab = {}
   for i=1,len do
       srcTab[i] = string.sub(str,i,i)
   end
   return srcTab
end
--简单tab转字符串
function ExternalFun.Tab2String(tab)
   local src=""
   for i,v in pairs(tab) do
      if v ~= 0 then
         src = src..v
      end
   end
   return tostring(src)
end

function ExternalFun.HxStringEncode(src)
    math.randomseed( os.time())
    local len = string.len(src)
    local srcBin = ExternalFun.String2Tab(src)
    local des = {}
    for i=0,len*4+1 do
        des[i+1] = 0
    end
    for i=0,len-1 do
       local a = string.byte(srcBin[i+1],1,1)
       local b = math.random(0,255)
       local desBin = bit:_xor(a,b)
       local temp = string.format("%02X%02X",desBin,b)
       temp = ExternalFun.String2Tab(temp)
	   des[i * 4 + 0+1] = temp[0+1]
	   des[i * 4 + 1+1] = temp[2+1]
	   des[i * 4 + 2+1] = temp[1+1]
	   des[i * 4 + 3+1] = temp[3+1]
    end
    local pOut = ExternalFun.Tab2String(des)
    return pOut
end
function ExternalFun.HxStringDecode(src)
    local srcLen = string.len(src)
    local srcBin = {}
    for i=0, math.floor(srcLen/2)+1 do
        srcBin[i+1] = 0
    end
    src = ExternalFun.String2Tab(src)
    local srcBin = ""
    for i=0, math.floor(srcLen/4)-1 do
        local temp = {0,0,0,0,0}
		temp[0+1] = src[i * 4 + 0+1]
		temp[1+1] = src[i * 4 + 2+1]
		temp[2+1] = src[i * 4 + 1+1]
		temp[3+1] = src[i * 4 + 3+1]

        local tmp1 = temp[0+1]..temp[1+1]
        local tmp2 = temp[2+1]..temp[3+1]
        --tmp1 = string.format("%02x",tmp1)
        local rndBin = tonumber(tmp1, 16)  --string.byte(tmp1,1,#tmp1)
        local desBin = tonumber(tmp2, 16)  --string.byte(tmp2,1,#tmp2)
        local aa =bit:_xor(desBin,rndBin)
        
        srcBin = srcBin.. string.char(aa)
    end
    return srcBin
end


--创建一个Layout按钮
function ExternalFun.createLayoutButton(parentNode, size, pos, callBack)
    local layoutButton = ccui.Layout:create()
    :setAnchorPoint(cc.p(0.5, 0.5))
    :setContentSize(size)
    :setPosition(pos)
    :addTo(parentNode)
    layoutButton:setCascadeOpacityEnabled(true)

    local function touchCallBack(event)
        if event.name == "ended" then
            if not tolua.isnull(layoutButton) then
                layoutButton:stopAllActions()
                layoutButton:setScale(1.0)
                local scaleBig = cc.ScaleTo:create(0.05, 1.05)
                local scaleSrc = cc.ScaleTo:create(0.05, 1.0)
                local callFun = cc.CallFunc:create(function()
                    if callBack then
                        callBack()
                    end
                end)
                layoutButton:setTouchEnabled(false)
                local timeDelay = cc.DelayTime:create(0.5)
                local callFun2 = cc.CallFunc:create(function()
                    layoutButton:setTouchEnabled(true)
                end)
                local seq = cc.Sequence:create(scaleBig, scaleSrc, callFun, timeDelay, callFun2)
                layoutButton:runAction(seq)
            end
        end
    end

    layoutButton:setTouchEnabled(true)
    layoutButton:onTouch(touchCallBack)

    return layoutButton
end

-- spine by cgq
function ExternalFun.newAnimationSpine(pkid,name,path,timeScale)
    if timeScale == nil then
        timeScale = 1.0
	end
	if ExternalFun.spineResList == nil then
		ExternalFun.spineResList = {}
	end
	if ExternalFun.spineResList[pkid] == nil then
		ExternalFun.spineResList[pkid] = {}
	end
	local animation = sp.SkeletonAnimation:create(path..name..".json",path..name..".atlas",timeScale)
	ExternalFun.spineResList[pkid][path..name] = path..name..".png"
	-- 播放动画
	function animation:playAnimation(name,trackIndex,isLoop)
		if trackIndex == nil then
			trackIndex = 0
		end
		if isLoop == nil then
			isLoop = false
		end
		self:setToSetupPose()
		self:setAnimation(trackIndex,name,isLoop)
		return self
	end
	-- stop
	function animation:stopAnimation()
		self:clearTracks()
		return self
	end
    
    return animation
end

function ExternalFun.removeAnimationSpine(pkid)
	if ExternalFun.spineResList and ExternalFun.spineResList[pkid] then
		for key,var in pairs(ExternalFun.spineResList[pkid]) do
			print("removeAnimationSpine",var)
			cc.Director:getInstance():getTextureCache():removeTextureForKey(var)
		end
		ExternalFun.spineResList[pkid] = nil
	end
end

-- 数字滚动，增减，变色 by cgq
function ExternalFun.digitalScroll(txt,changeNum,parame,callback)
	if txt == nil then
		return
	end
	local numper = changeNum/15
	local numperA = 15
	local color = txt:getColor()
	local isColor = parame and parame.isColor or false
	if changeNum == 0 then
		return
	elseif changeNum > 0 then
		if isColor then
			txt:setColor(cc.c3b(57,245,207))
		end
	else
		if isColor then
			txt:setColor(cc.c3b(245,57,101))
		end
		changeNum = -changeNum
	end

	local charAdd = parame and parame.charAdd or nil
	local charSub = parame and parame.charSub or nil
	local charFg = parame and parame.charFg or nil

	local str = txt:getString()
	str = string.gsub(str,"[%.,]","")
	if charFg then
		str = tonumber((string.gsub(str,charFg,"")))
	end
	local num = tonumber(str)
	if num == nil then
		num = 0
	end

	-- 开启计时器
	local function tmCallback()
		num = num+numper
		numperA = numperA-1

		local tonum = math.floor(num+0.5)
		local tonumO = tonum
		if charFg and tonum >= 1000 then
			-- tonum = ExternalFun.formatnumberthousands(tonum,charFg)
			tonum = ExternalFun.formatnumberthousands(tonum)
		end
		
		if charAdd and tonumO > 0 then
			tonum = ""..charAdd..tonum
		elseif charSub and tonumO < 0 then
			tonum = ""..charSub..tonum
		end

		txt:setString(g_format:formatNumber(tonum,g_format.fType.standard,g_format.currencyType.GOLD))

		if numperA <= 0 then
			txt:stopAllActions()
			if isColor then
				txt:setColor(color)
			end
			-- 回调
			if callback then
				callback()
			end
		end
	end
	schedule(txt,tmCallback,0.05)

end

-- ui open action by cgq
function ExternalFun.openLayerAction(node,callback)
    node:setScale(0.3)
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0),cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end
function ExternalFun.closeLayerAction(node,callback)
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.01),cc.ScaleTo:create(0.15,0.1),cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end

--创建序列帧动画
function ExternalFun.createFramesAnimation(prefix, fileName, frameName, fps, isLoop, isAutoRemove, startIdx, endIdx, waitTime)
    ExternalFun.framesCache = ExternalFun.framesCache or {}

    waitTime = waitTime or 0

    local plistName = string.format('%s%s.plist', prefix, fileName)
    local pngName = string.format('%s%s.png', prefix, fileName)

    if not ExternalFun.framesCache[fileName] then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName, pngName)
        ExternalFun.framesCache[fileName] = true
    end
    local framesNum = 0
    if startIdx and endIdx then
        framesNum = endIdx - startIdx + 1
    else
        local plistPath = cc.FileUtils:getInstance():fullPathForFilename(plistName)  
        local plistDict = cc.FileUtils:getInstance():getValueMapFromFile(plistPath)  
        local plistFrames = plistDict['frames']
        dump(plistFrames,"信息输出", 10)
        
        local numTable = {}
        for k,v in pairs(plistFrames) do
            local index, endindex = string.find(k, frameName)
            if index then
                local num = string.gsub(k, frameName, '')
                num = string.gsub(num, '.png', '')
                num = tonumber(num)
                table.insert(numTable, num)
            end
        end

        table.sort(numTable, function(a, b)
            return a < b
        end)
        startIdx = numTable[1]
        framesNum = #numTable
    end

    local frameFile = string.format('%s%%02d.png', frameName)
    dump(frameFile, "文件名是", 10)
    local frames = display.newFrames(frameFile, startIdx, framesNum)
    local sprite = display.newSprite('#' .. string.format(frameFile, startIdx))

    local seqTable = {}
    local animation = display.newAnimation(frames, fps)
    local act = cc.Animate:create(animation)
    local cFun = cc.CallFunc:create(function()
        print('end')
        if not tolua.isnull(sprite) then
            sprite:removeFromParent()
        end
    end)

    table.insert(seqTable, act)
    if not isLoop and isAutoRemove then
        table.insert(seqTable, cFun)
    end
    
    if waitTime ~= 0 then
        local delayTimeEnd = cc.DelayTime:create(waitTime)
        table.insert(seqTable, delayTimeEnd)
    end

    local seq = cc.Sequence:create(seqTable)
    local rep = cc.RepeatForever:create(seq)
    if isLoop then
        sprite:runAction(rep)
    else
        sprite:runAction(seq)
    end
    
    return sprite
end

--人民币阿拉伯数字转大写(带零)
function ExternalFun.numberTransiformEx(strCount)
	local big_num = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"}
	local big_mt = {__index = function() return "" end }
	setmetatable(big_num,big_mt)
	local unit = {"元", "拾", "佰", "仟", "万",
                  --拾万位到千万位
                  "拾", "佰", "仟",
                  --亿万位到万亿位
                  "亿", "拾", "佰", "仟", "万",}
    local unit_mt = {__index = function() return "" end }
    setmetatable(unit,unit_mt)
    local tmp_str = ""
    local len = string.len(strCount)
    for i = 1, len do
    	tmp_str = tmp_str .. big_num[string.byte(strCount, i) - 47] .. unit[len - i + 1]
    end
    return strCount == 0 and ExternalFun.replaceAll(tmp_str, "元", "") or ExternalFun.cleanZero(tmp_str)
end


function ExternalFun.replaceAll(src, regex, replacement)
	return string.gsub(src, regex, replacement)
end

--保留n位小数，支持负数
function ExternalFun.keepDecimal(_nums, n)
	if type(_nums) ~= "number" then
		return _nums
	end
	local v1, v2 = math.modf(_nums)
	if v2 == 0 then
		--整数不处理
		return _nums
	end
	n = n or 2
	if _nums < 0 then
		return -(math.abs(_nums) - math.abs(_nums) % 0.1 ^ n)
	else
		return _nums - _nums % 0.1 ^ n
	end
end

--格式化数字并把点号替换为逗号
function ExternalFun.formatNumWithPeriod(_strNum, _moreFormat, _bitNum)
    if type(_strNum) ~= "number" and not tonumber(_strNum) then
        return
    end
    _strNum = tonumber(_strNum)
    _bitNum = _bitNum or 2
    _moreFormat = _moreFormat == nil and "" or _moreFormat
    local formatStr = "%." .. _bitNum .. "f" .. _moreFormat
    local numStr = string.format(formatStr, _strNum)
    numStr = string.gsub(numStr, "%.", ",")
    return numStr
end


function ExternalFun.ClipHead(pNode,pPathHead,pPathClip)	
	--创建裁剪
	local strClip = pPathClip	
	local clipSp = cc.Sprite:create(strClip)	
	if nil ~= clipSp then
		local pNodeSize = pNode:getContentSize()		
		local spRender = cc.Sprite:create(pPathHead)
		if not spRender then return end
		spRender:setContentSize(pNodeSize)
		--裁剪
		local clip = cc.ClippingNode:create()
		clip:setStencil(clipSp)
		clip:setAlphaThreshold(0.05)
		clip:addChild(spRender)
		clip:setContentSize(pNodeSize)
		clip:setPosition(cc.p(pNodeSize.width * 0.5, pNodeSize.height * 0.5))
		pNode:addChild(clip)
	end
end

--中文匹配
-- local function CheckChinese(s) 
-- 	local ret = {};	
--     local f = '[%z\1-\9\11-\255][256-376]*';
-- 	local line, lastLine, isBreak = '', false, false;	
-- 	for v in s:gmatch(f) do		
-- 		table.insert(ret, {c=v,isChinese=(#v~=1)});
-- 	end
-- 	print("s = ",s)
-- 	dump(ret)
-- 	return ret;
-- end

--检查特殊符号
-- local function filter_spec_chars(s)
--     local ss = {} --数字和字母
--     local CN = {} --中文
--     local sym = {} --特殊符号
--     local filterCn = {} --除了中文
--     local k = 1

--     while true do
--         if k > #s then
--             break
--         end
--         local c = string.byte(s, k)
-- 		print("c = ",c)
--         if not c then
--             break
--         end
--         if c < 192 then
--             if (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
--                 table.insert(ss, string.char(c))
--             else
--                 table.insert(sym,string.char(c))
--             end
--             table.insert(filterCn,string.char(c))
--             k = k + 1
--         elseif c < 224 then
--         	local c1 = string.byte(s, k + 1)
-- 	        table.insert(filterCn, string.char(c, c1))
--             k = k + 2
--         elseif c < 240 then
--         	local c1 = string.byte(s, k + 1)
--             local c2 = string.byte(s, k + 2)
--             if c >= 228 and c <= 233 then
--                 if c1 and c2 then
--                     local a1, a2, a3, a4 = 128, 191, 128, 191

--                     if c == 228 then
--                         a1 = 184
--                     elseif c == 233 then
--                         a2, a4 = 190, c1 ~= 190 and 191 or 165
--                     end

--                     if c1 >= a1 and c1 <= a2 and c2 >= a3 and c2 <= a4 then
--                         table.insert(CN, string.char(c, c1, c2))
--                     else
--                     	table.insert(filterCn, string.char(c, c1, c2))
--                     end
--                 else
--                 	table.insert(filterCn, string.char(c, c1, c2))
--                 end
--             else
--             	table.insert(filterCn, string.char(c, c1, c2))
--             end
--             k = k + 3
--         elseif c < 248 then
--         	local c1 = string.byte(s, k + 1)
--             local c2 = string.byte(s, k + 2)
--             local c3 = string.byte(s, k + 3)
--             table.insert(filterCn, string.char(c, c1, c2, c3))
--             k = k + 4
--         elseif c < 252 then
--         	local c1 = string.byte(s, k + 1)
--             local c2 = string.byte(s, k + 2)
--             local c3 = string.byte(s, k + 3)
--             local c4 = string.byte(s, k + 4)
--             table.insert(filterCn, string.char(c, c1, c2, c3, c4))
--             k = k + 5
--         elseif c < 254 then
--         	local c1 = string.byte(s, k + 1)
--             local c2 = string.byte(s, k + 2)
--             local c3 = string.byte(s, k + 3)
--             local c4 = string.byte(s, k + 4)
--             local c5 = string.byte(s, k + 5)
--             table.insert(filterCn, string.char(c, c1, c2, c3, c4, c5))
--             k = k + 6
--         end
--     end

--     --return table.concat(ss)
-- 	--dump(filterCn)
--     return table.concat(filterCn)
-- end
-- --剔除中文
-- function ExternalFun.RejectChinese(pString)	
-- 	local result = ""
-- 	-- if pString and pString~="" then
-- 	-- 	for k, v in ipairs(CheckChinese(pString)) do
-- 	-- 		if not v.isChinese then
-- 	-- 			result = result .. v.c
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- 	result = filter_spec_chars(pString)
-- 	return result
-- end

-- -- 定义一个函数，用于判断字符是否为中文字符
-- local function isChineseChar(c)
--     -- 中文字符的 Unicode 编码范围是 [\u4e00-\u9fa5]
--     return c:byte() >= 0x4e00 and c:byte() <= 0x9fa5
-- end

-- function ExternalFun.RejectChinese(pString)
-- 	local result = ""	
--     for i = 1, #pString do
--         local c = pString:sub(i, i)
--         if not isChineseChar(c) then
--             result = result .. c
--         end
--     end
--     return result
-- end

-- 剔除中文和特殊符号
function ExternalFun.RejectChinese(str)
    local result = {}    
    for c in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local b = string.byte(c)
        if b >= 228 and b <= 233 then    
        else
            table.insert(result, c)
        end
    end   
	local resultString = table.concat(result)
	if resultString~=str then
		--上报埋点
		EventPost:addCommond(EventPost.eventType.COLLECT,"上报包含中文的提示语句："..str,nil,nil,nil)
	end
    return resultString
end

function ExternalFun.ccpCopy(ccpointOrX, y)
    if y then
        return cc.p(ccpointOrX, y)
    else
        return cc.p(ccpointOrX.x, ccpointOrX.y);
    end
end

--获取客服列表第一条和常用的url
function ExternalFun.getCustomerUrl(_pType)
    local urlKey = string.format("custom_type_%d_%d", _pType, GlobalUserItem.dwUserID)
    local strUrl = cc.UserDefault:getInstance():getStringForKey(urlKey, "") --获取常用的客服链接
    local firstEnabledUrl = ""
    local isLegal = false
    --获取第一个合法的url,并检查strUrl是否合法
    for j, k in ipairs(GlobalData.CustomerInfos[_pType] or {}) do
        if k ~= "" then
            if firstEnabledUrl == "" then
                firstEnabledUrl = k
            end
            if strUrl ~= "" then
                if k == strUrl then
                    isLegal = true
                end
            end
        end
    end
    if not isLegal then
        strUrl = firstEnabledUrl
    end
    print('ExternalFun.getCustomerUrl strUrl is ', firstEnabledUrl, strUrl, isLegal, _pType, urlKey)
    return firstEnabledUrl, strUrl
end

-- --获取一个字符串实际的长度(汉字归为1长度),返回长度以及(剔除可能存在错误编码的)原字符
function ExternalFun.getUtf8Len(_str)
    local len  = string.len(_str)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local temp = left
    while left > 0 do
        local tmp = string.byte(_str, -left)
        if tmp then
            local i = #arr
            while arr[i] do
                if tmp >= arr[i] then
                    temp = left
                    left = left - i
                    if left < 0 then --概率会出现在最后一个字符上(某个字节被截断了)，例如通过链接修改玩家名字之类的
                        local str = string.sub(_str, 1, -temp - 1)
                        return cnt, str
                    end
                    break
                end
                i = i - 1
            end
        else
            local str = string.sub(_str, 1, -temp - 1)
            return cnt, str
        end
        cnt = cnt + 1
    end
    return cnt, _str
end

--获取一个字符串实际的长度(汉字归为1长度),返回长度以及(剔除可能存在错误编码的)原字符
--ChatGPT 优化版本
--[[
function ExternalFun.isUtf8(str)
    local i, len = 1, #str
    while i <= len do
        local c = string.byte(str, i)
        local count = 1
        if c >= 0xC0 and c <= 0xDF then
            count = 2
        elseif c >= 0xE0 and c <= 0xEF then
            count = 3
        elseif c >= 0xF0 and c <= 0xF7 then
            count = 4
        elseif c >= 0xF8 and c <= 0xFB then
            count = 5
        elseif c >= 0xFC and c <= 0xFD then
            count = 6
        end

        if i + count - 1 > len then
            return false
        end

        for j = 1, count - 1 do
            if string.byte(str, i + j) < 0x80 or string.byte(str, i + j) > 0xBF then
                return false
            end
        end

        i = i + count
    end

    return true
end

function ExternalFun.getUtf8Len(_str)
    local len = string.len(_str)
    local left, cnt = len, 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local str = ""
    
    for i = 1, len do
        local byte = string.byte(_str, i)
        if left <= 0 then
            break
        end
        
        if byte >= 0 and byte <= 127 then
            str = str .. string.char(byte)
            cnt = cnt + 1
            left = left - 1
        else
            local offset = 6
            while offset > 0 do
                if byte >= arr[offset] then
                    local char_len = offset
                    if left < char_len then
                        break
                    end
                    
                    local char_str = string.sub(_str, i, i + char_len - 1)
                    if ExternalFun.isUtf8(char_str) then
                        str = str .. char_str
                        cnt = cnt + 1
                        left = left - char_len
                    else
                        break
                    end
                end
                offset = offset - 1
            end
        end
    end

    return cnt, str
end
--]]
function ExternalFun.getUtf8Len(_str)
    local len = #_str
    local left, cnt = len, 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left > 0 do
        local tmp = string.byte(_str, -left)
        if not tmp then
            break
        end
        local i = #arr
        while arr[i] and tmp < arr[i] do
            i = i - 1
        end
        left = left - i
        cnt = cnt + 1
        if left < 0 then
            return cnt - 1, string.sub(_str, 1, len + left - i)
        end
    end
    return cnt, _str
end

--获取目标长度的字符串，汉字算1个长度
function ExternalFun.getDstLengthStr(_str, _length, _dstLength)
	local newStr = string.sub(_str, 1, _length)
	local length, strTemp = ExternalFun.getUtf8Len(newStr)
	-- tlog("dst ", length, strTemp, _length, _dstLength)
	if length < _dstLength then
		return ExternalFun.getDstLengthStr(_str, _length + 1, _dstLength)
	else
		return newStr
	end
end
--生成roomMark 唯一房间号
function ExternalFun.getRoomMark(kindID,serverKind,sortID)
	return kindID*1000 + serverKind*10 + sortID	
end
--获取kind
function ExternalFun.getKindID(roomMark)
    return math.modf(roomMark/1000)
end
--获取 serverKind
function ExternalFun.getServerKind(roomMark)
	local remainder = math.fmod(roomMark,1000)
	return math.modf(remainder/10)
end
--获取sort
function ExternalFun.getSortID(roomMark)
	return math.fmod(roomMark,10)  --对10取余 得个位数
end

--判定属于EasyGame
function ExternalFun.isEasyGame(pID)
	return GlobalData.EasyGameID[pID]
end

--判定属于PocketGame
function ExternalFun.isPocketGame(pID)
	return GlobalData.PocketGameID[pID]
end


function ExternalFun.setIcon(pNode,currencyType)
	local goldPath = "client/res/public/gold_icon.png"
	local tcPath = "client/res/public/tc_icon.png"
	local curPath = goldPath
	if currencyType == 2 then 
		currencyType = G_NetCmd.GAME_KIND_TC
	end
	if currencyType == G_NetCmd.GAME_KIND_TC then
		curPath = tcPath
	end
	if pNode.loadTexture then
		pNode:loadTexture(curPath)
	else
		pNode:setTexture(curPath)
	end
end

function ExternalFun.adapterScreen(pObj)
	if display.width  > 2560 then
        pObj:setScale(display.width/2560)
    end
end

return ExternalFun