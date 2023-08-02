function string.findlast(s, pattern, plain)
    local curr = 0
    repeat
        local next = s:find(pattern, curr + 1, plain)
        if next then curr = next end
    until (not next)

    if curr > 0 then
        return curr
    end
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function string.formatNumberThousands(num,dot,flag)
	local formatted = 0 
	if not dot then
    	formatted = string.format("%0.2f",tonumber(num))
    else
    	formatted = tonumber(num)
    end
    local sp
    if not flag then
    	sp = ","
    else
    	sp = flag
    end
	if formatted ==nil then
		return 0
	end	
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1'..sp..'%2')
        if k == 0 then break end
    end
    return formatted
end

path = {}

function path.getname(p)
    local i = p:findlast("[/\\]")
    if i then
        return p:sub(i + 1)
    else
        return p
    end
end

function path.getext(p)
    local i = p:findlast(".", true)
    if i then
        return p:sub(i)
    else
        return ""
    end
end

function path.getdir(p)
    local i = p:findlast("[/\\]")
    if i then
        if i > 1 then i = i - 1 end
        return p:sub(1, i)
    else
        return "."
    end
end

function path.getbasename(p)
    local name = path.getname(p)
    local i = name:findlast(".", true)
    if i then
        return name:sub(1, i - 1)
    else
        return name
    end
end

function path.join(p1, p2, ...)
    if not p2 then return p1 end
    if #p1 == 0 then return p2 end

    local s = string.char(string.byte(p1, #p1))

    if s == '/' or s == '\\' then
        return path.join(p1 .. p2, ...)
    else
        return path.join(p1..'/'..p2, ...)
    end
end


http = {}

function http.get(info)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET", info.url)

    xhr:registerScriptHandler(function()
        local ok, str, err
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            ok, str = true, xhr.response
        else
            err = string.format("网络错误:%d-%d", xhr.readyState, xhr.status)
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

function http.get_json(info)
    local cb = info.callback
    info.callback = function(ok, str)
        if ok then
            local err
            local ok, jsondata = xpcall(function() return cjson.decode(str) end, function(e) err = e end)
            if ok then
                cb(true, jsondata, str)
            else
                cb(false, "解析错误："..err)
            end
        else
            cb(false, str)
        end
    end
    return http.get(info)
end
function parseInt(value)
    if type(value) ~= "number" then
        value = tonumber(value)
    end
    return math.floor(value or 0);
end
--显示提示消息
local msgTab = {}
local maxMsg = 3
local count = 0

function showToast(message,color)
    if (message == nil) or message == "" then
        return
    end
    --移除中文
    message = g_ExternalFun.RejectChinese(message)
    
    if cc.exports.msgBoxNode and not tolua.isnull(cc.exports.msgBoxNode) then
    else            
        cc.exports.msgBoxNode = appdf.req("base/src/app/common/ui/msg/topWidget").new() 
    end
    cc.exports.msgBoxNode:showMsg(message)
end
function showToastGreen(message,color)
    if (message == nil) or message == "" then
        return
    end
    if cc.exports.msgBoxNode and not tolua.isnull(cc.exports.msgBoxNode) then
    else            
        cc.exports.msgBoxNode = appdf.req("base/src/app/common/ui/msg/topWidget").new() 
    end
    cc.exports.msgBoxNode:showMsg(message)
end
function showToastRed(message,color)
	 if (message == nil) or message == "" then
	 	return
	 end
     if cc.exports.msgBoxNode and not tolua.isnull(cc.exports.msgBoxNode) then
     else            
         cc.exports.msgBoxNode = appdf.req("base/src/app/common/ui/msg/topWidget").new() 
     end
     cc.exports.msgBoxNode:showMsg(message)
end
-- 删除并返回第一个
function shift(t)
    local result = nil;
    result = t[1];
    if result then
        table.remove(t, 1);
    end
    return result;
end
local aphpaBgDuration = 0.3
local zoomDuration = 0.2;
local alphaDuration = 0.25;
--创建通用弹出界面动画功能函数,bg背景遮罩，node节点
function ShowCommonLayerAction(bg,node,callback)
    if node == nil then return end
    if TweenLite == nil then
        if bg then
            bg:runAction(cc.FadeTo:create(0.2,255))
        end
        local pOriginScale = node:getScale()
        local scale1 = cc.ScaleTo:create(0.11,1.1*pOriginScale)
        local scale2 = cc.ScaleTo:create(0.11,1*pOriginScale)
        node:runAction(cc.Sequence:create(scale1,scale2,cc.CallFunc:create(function() 
           if callback then
               callback()
           end
        end)))
        return
    end
    if bg then
        bg:setOpacity(0)
        -- bg:setContentSize(2340,1080)
        bg:setContentSize(display.size)
        TweenLite.to(bg, aphpaBgDuration, { autoAlpha = 1 })
    end
    local tl = TimelineLite.new({onComplete = callback})
    local pOriginScale = node:getScale()
    node:setScale(0.5*pOriginScale)    
    tl:append(TweenLite.to(node, 0.22, {scaleX = pOriginScale, scaleY = pOriginScale,ease = Back.easeOut}))
end

function DoHideCommonLayerAction(bg,node,callback)
    if node == nil then return end
    if TweenLite == nil then
        if callback then
            callback()
        end
        return
    end
    if bg then
        TweenLite.to(bg, aphpaBgDuration, { autoAlpha = 0 })  
    end
    TweenLite.to(node, alphaDuration, { autoAlpha = 0 })
    TweenLite.to(node, zoomDuration, { scale=0.01, onComplete =callback })    
end

--系统全局喇叭
function ShowTrumpMsg(nickName,roomName,score)
    local scene = cc.Director:getInstance():getRunningScene()
    if not scene then 
       print("cur scene not exist")
    end
    local csbTrump = cc.CSLoader:createNode("hall/layer_trump.csb")
    csbTrump:setPosition(142,750)
    scene:addChild(csbTrump,1000)
    local panel = csbTrump:getChildByName("panel_trump")
    local skeletonNode = sp.SkeletonAnimation:create("spine/trump/jxlw_firetioskuangeffecta.json", "spine/trump/jxlw_firetioskuangeffecta.atlas", 1)
    skeletonNode:setAnimation(0, "start", false)
    skeletonNode:addAnimation(0, "idle", true)
    skeletonNode:setScaleX(1.5)
    skeletonNode:setPosition(525,25)
    panel:addChild(skeletonNode)
    local _node = cc.Node:create()
    panel:addChild(_node)

    local _width = 0
    local _height = 25
    local _txt =  cc.Label:createWithTTF("恭喜", "fonts/round_body.ttf", 28)
    _txt:setAnchorPoint(0,0)
    _txt:setColor(cc.c3b(214,222,224))   
    _txt:setPosition(_width,_height)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)

    _width = _width + 2
    _txt =  cc.Label:createWithTTF(nickName, "fonts/round_body.ttf", 28)
    _txt:setColor(cc.c3b(150,211,203))
    _txt:setAnchorPoint(0,0)
    _txt:setPosition(_width,_height)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)
    _width = _width + 2
    _txt =  cc.Label:createWithTTF("在", "fonts/round_body.ttf", 28)
    _txt:setAnchorPoint(0,0)
    _txt:setColor(cc.c3b(214,222,224))  
    _txt:setPosition(_width,_height)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)
    _width = _width + 2
    _txt =  cc.Label:createWithTTF(roomName, "fonts/round_body.ttf", 28)
    _txt:setColor(cc.c3b(216,157,116))
    _txt:setAnchorPoint(0,0)
    _txt:setPosition(_width,_height)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)
    _width = _width + 2
    _txt =  cc.Label:createWithTTF("获得", "fonts/round_body.ttf", 28)
    _txt:setAnchorPoint(0,0)
    _txt:setColor(cc.c3b(214,222,224))  
    _txt:setPosition(_width,_height)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)

    _width = _width + 2
    local _sp = cc.Sprite:createWithSpriteFrameName("datingjindou.png")
    _sp:setAnchorPoint(0,0)
    _sp:setPosition(_width,_height)
    _width = _width + _sp:getContentSize().width
    _node:addChild(_sp)

    _width = _width + 2
	local str = string.formatNumberThousands(score,true,",")
    _txt =  cc.Label:createWithTTF(str, "fonts/round_body.ttf", 30)
    _txt:setColor(cc.c3b(214,162,87))
    _txt:setAnchorPoint(0,0)
    _txt:setPosition(_width,_height-2)
    _width = _width + _txt:getContentSize().width
    _node:addChild(_txt)
    local _nodePosX = (1050 - _width )/2
    _node:setPosition(_nodePosX,-5)
    local moveTo = cc.MoveTo:create(0.1,cc.p(142,660))
    local seq = cc.Sequence:create(moveTo,cc.DelayTime:create(5),cc.CallFunc:create(function()
        csbTrump:removeSelf()
    end))
    csbTrump:runAction(seq)
end

function split2Tab(str,delim)
	local i,j,k
	local t = {}
	k = 1
	while true do
		i,j = string.find(str,delim,k)
		if i == nil then
			table.insert(t,tonumber(string.sub(str,k)))
			return t
		end
		table.insert(t,tonumber(string.sub(str,k,i - 1)))
		k = j + 1
	end
    return t
end

--依据宽度截断字符
function stringEllipsis(szText, sizeE,sizeCN,maxWidth)
	--当前计算宽度
	local width = 0
	--截断位置
	local lastpos = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	local i = 1
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width +sizeCN <= maxWidth - 3*sizeE then
				width = width +sizeCN
				 i = i + 3
				 lastpos = i+2
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width +sizeE <= maxWidth - 3*sizeE then
				width = width +sizeE
				i = i + 1
				lastpos = i
			else
				bOK = true
				break
			end
		else
			i = i + 1
			lastpos = i
		end
	end
	if lastpos ~= 0 then
		szResult = string.sub(szText, 1, lastpos)
		if(bOK) then
			szResult = szResult.."..."
		end
	end
	return szResult
end

function getNodeByName(node,name)
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
function ccui.Widget:onClickEnd(f, isClose, nosacle,checkMove)
	local srcScale = 1
    nosacle = nosacle or false
    self._checkMove = checkMove
    self._applyFunc = true
	self:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
            if isClose == true then
                g_ExternalFun.playEffect("sound/btn_close.mp3")
            elseif isClose ~= false then
                g_ExternalFun.playEffect("sound/music_button.mp3")
            end
            self:setScale(srcScale)
            if self._applyFunc == true then
                if self.lastTouchTime == nil or socket.gettime() - self.lastTouchTime > ylAll.touchTime then
                    f(self)
                    self.lastTouchTime = socket.gettime()
                end
            end
		elseif eventType == ccui.TouchEventType.moved then
            self:setScale(srcScale)
            self._touchMovePos = sender:getTouchMovePosition()
            if self._checkMove==true and self._applyFunc ==true then
                if self._touchPos then
                    if abs(self._touchPos.x - self._touchMovePos.x) >= 20 then
                        self._applyFunc = false
                    end
                end
            end
        elseif eventType == ccui.TouchEventType.began then
            if not nosacle then
               self:setScale(srcScale+0.02)
            end
            self._touchPos = sender:getTouchBeganPosition()
            self._applyFunc = true
        end
	end)
end
function ccui.EditBox:setString(s)
	self:setText(s)
end
function ccui.EditBox:getString()
	return self:getText()
end
function ccui.TextField:getText()
	return self:getString()
end

function ccui.EditBox:onReturn(func1,func2,func3)
	self:registerScriptEditBoxHandler(function(name)
		if func1 and name == "began" then
			func1()
		end
		if func2 and name == "changed" then
			func2()
		end
		if func3 and name == "return" then
			func3()
		end
	end)
end

function ccui.EditBox:onDidReturn(func)
	self:registerScriptEditBoxHandler(function(name)
		if func and name == "return" then
			func()
		end
	end)
end

function ccui.TextField:onReturn(func)
	self._ok_func = func
end

function ccui.TextField:onTextChange(f)
	self:addEventListener(function(_, e)
		if e == ccui.TextFiledEventType.insert_text  or
			e==ccui.TextFiledEventType.delete_backward then
			f()
		end
	end)
end

function ccui.EditBox:onTextChange(f)
	self:registerScriptEditBoxHandler(function(e)
		if e == 'changed' then
			f()
		end
	end)
end

function ccui.TextField:convertToEditBox(inputmode,maxLength)
	local size = self:getContentSize()
	local box = ccui.EditBox:create(cc.size(size.width, size.height), "")

	box:setName(self:getName())
	box:setText(self:getString())
	box:setPosition(self:getPosition())
	box:setAnchorPoint(self:getAnchorPoint())

	box:setPlaceHolder(self:getPlaceHolder())
	box:setPlaceholderFontSize(self:getFontSize())
	box:setPlaceholderFontColor(cc.c3b(204,117,46))
	if inputmode then
		box:setInputMode(inputmode)
	else
		box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	end
    if maxLength then
        box:setMaxLength(maxLength)
    end
	box:setFontName(self:getFontName())
	box:setFontSize(self:getFontSize()-2)
	box:setFontColor(self:getColor())
	box:addTo(self:getParent())

	if self:isPasswordEnabled() then
		box:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	else
		box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
	end

	self:removeSelf()
	return box
end

function dwIp2String(ipaddr)
     if  ipaddr == nil then
       return "utils_int2stringIP error:para is nil"
     end
     local intnum = tonumber(ipaddr)
     local value0,value1,value2,value3
     assert(intnum)
     value3 =  bit.band( bit.rshift(intnum,24),0xff)
     value2 =  bit.band( bit.rshift(intnum,16),0xff)
     value1 =  bit.band( bit.rshift(intnum,8),0xff)
     value0 =  bit.band( bit.rshift(intnum,0),0xff)
     local IPstring = ( value0.."."..value1.."."..value2.."."..value3)
     return IPstring
end

function IpString2dw( str )
	local num = 0
	if str and type(str)=="string" then
		local o1,o2,o3,o4 = str:match("(%d+)%.(%d+)%.(%d+)%.(%d+)" )
		num = 2^24*o4 + 2^16*o3 + 2^8*o2 + o1
	end
    return num
end
local mg_CrcTable = {
	[0]=0x00,0x96,0x2C,0xBA,0x19,0x8F,0x35,0xA3,0x32,0xA4,0x1E,0x88,0x2B,0xBD,0x07,0x91,
	0x64,0xF2,0x48,0xDE,0x7D,0xEB,0x51,0xC7,0x56,0xC0,0x7A,0xEC,0x4F,0xD9,0x63,0xF5,
	0xC8,0x5E,0xE4,0x72,0xD1,0x47,0xFD,0x6B,0xFA,0x6C,0xD6,0x40,0xE3,0x75,0xCF,0x59,
	0xAC,0x3A,0x80,0x16,0xB5,0x23,0x99,0x0F,0x9E,0x08,0xB2,0x24,0x87,0x11,0xAB,0x3D,
	0x90,0x06,0xBC,0x2A,0x89,0x1F,0xA5,0x33,0xA2,0x34,0x8E,0x18,0xBB,0x2D,0x97,0x01,
	0xF4,0x62,0xD8,0x4E,0xED,0x7B,0xC1,0x57,0xC6,0x50,0xEA,0x7C,0xDF,0x49,0xF3,0x65,
	0x58,0xCE,0x74,0xE2,0x41,0xD7,0x6D,0xFB,0x6A,0xFC,0x46,0xD0,0x73,0xE5,0x5F,0xC9,
	0x3C,0xAA,0x10,0x86,0x25,0xB3,0x09,0x9F,0x0E,0x98,0x22,0xB4,0x17,0x81,0x3B,0xAD,
	0x20,0xB6,0x0C,0x9A,0x39,0xAF,0x15,0x83,0x12,0x84,0x3E,0xA8,0x0B,0x9D,0x27,0xB1,
	0x44,0xD2,0x68,0xFE,0x5D,0xCB,0x71,0xE7,0x76,0xE0,0x5A,0xCC,0x6F,0xF9,0x43,0xD5,
	0xE8,0x7E,0xC4,0x52,0xF1,0x67,0xDD,0x4B,0xDA,0x4C,0xF6,0x60,0xC3,0x55,0xEF,0x79,
	0x8C,0x1A,0xA0,0x36,0x95,0x03,0xB9,0x2F,0xBE,0x28,0x92,0x04,0xA7,0x31,0x8B,0x1D,
	0xB0,0x26,0x9C,0x0A,0xA9,0x3F,0x85,0x13,0x82,0x14,0xAE,0x38,0x9B,0x0D,0xB7,0x21,
	0xD4,0x42,0xF8,0x6E,0xCD,0x5B,0xE1,0x77,0xE6,0x70,0xCA,0x5C,0xFF,0x69,0xD3,0x45,
	0x78,0xEE,0x54,0xC2,0x61,0xF7,0x4D,0xDB,0x4A,0xDC,0x66,0xF0,0x53,0xC5,0x7F,0xE9,
	0x1C,0x8A,0x30,0xA6,0x05,0x93,0x29,0xBF,0x2E,0xB8,0x02,0x94,0x37,0xA1,0x1B,0x8D,
}
function Calc_crc(initial,buf,len)
    local c = bit:_xor(initial,0xFFFFFFFF)
    for i=0,len-1 do
        local a = bit:_xor(c,buf[i+1])
        local b = bit:_and(a,0xFF)
        local e = mg_CrcTable[b]
        local d = bit:_rshift(c,8)
        c = bit:_xor(e,d)
    end
    return bit:_xor(c,0xFFFFFFFF)
end
