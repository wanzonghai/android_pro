--新头像获取
local HeadSpriteNew = class("HeadSpriteNew",cc.Sprite)
local SYS_HEADSIZE = 200

local FACEDOWNLOAD_LISTENER = "face_notify_down"
local FACERESIZE_LISTENER = "face_resize_notify"
--全局通知函数
cc.exports.g_FaceDownloadListener = function (ncode, msg, filename)
	local event = {}
	event.code = ncode
	event.msg = msg
	event.filename = filename

	HeadSpriteNew:downloadFaceCallBack(event)
end

--
cc.exports.g_FaceResizeListener = function(oldpath, newpath)
	local event = {}
	event.oldpath = oldpath
	event.newpath = newpath

	HeadSpriteNew:reSizeCallBack(event)
end


function HeadSpriteNew:GetHeadSpriteNew(useritem,callback)
	local isThirdParty = useritem.bThirdPartyLogin or false	
	--系统头像
	local faceid = useritem.wFaceID or 0
	if faceid < 1 then faceid = 1 end
	if faceid >10 then faceid = 10 end
	local str = "public/Face"..faceid..".jpg"
	return str 
end

--下载头像
function HeadSpriteNew:downloadFace(url, path, filename, onDownLoadSuccess)
	local downloader = CurlAsset:createDownloader("g_FaceDownloadListener",url)			
	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end			

	self._onDownLoadSuccess = onDownLoadSuccess
	self.m_downListener = cc.EventListenerCustom:create(FACEDOWNLOAD_LISTENER,function()end)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_downListener, 1)
	downloader:downloadFile(path, filename)
end

function HeadSpriteNew:downloadFaceCallBack(event)
    if nil ~= event.filename and 0 == event.code then
    	if nil ~= self._onDownLoadSuccess 
    		and type(self._onDownLoadSuccess) == "function" 
    		and nil ~= event.filename 
    		and type(event.filename) == "string" then
    		   self._onDownLoadSuccess(event.filename)
    	end        	
    end
    if nil ~= self.m_downListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_downListener)
		self.m_downListener = nil
	end
end

function HeadSpriteNew:reSizeCallBack(event)
    if nil ~= self._onReSizeCallBack 
    	and type(self._onReSizeCallBack) == "function" then
    	  self._onReSizeCallBack(event)
    end        	
end

function HeadSpriteNew:createNormal(useritem, headSize)
    local _sprite = nil
    local spriteName = self:GetHeadSpriteNew(useritem,function(spiteName)
        _sprite = cc.Sprite:create(spiteName)
        _sprite:setScale(headSize/SYS_HEADSIZE)
    end)
    if spriteName then
        _sprite = cc.Sprite:create(spriteName)
        _sprite:setScale(headSize/SYS_HEADSIZE)
    end
    while true do
        if tolua.cast(_sprite,"cc.Sprite") then
            return _sprite
        end
    end
end

return HeadSpriteNew


