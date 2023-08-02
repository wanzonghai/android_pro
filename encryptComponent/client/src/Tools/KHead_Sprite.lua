
--
-- Author: zhong
-- Date: 2016-07-25 10:19:18
--
--游戏头像
local KHead_Sprite = class("KHead_Sprite", cc.Sprite)

--自定义头像存储规则
-- path/face/userid/custom_+customid.ry
--头像缓存规则
-- uid_custom_cusomid

local FACEDOWNLOAD_LISTENER = "face_notify_down"
local FACERESIZE_LISTENER = "face_resize_notify"
--全局通知函数
--[[
cc.exports.g_FaceDownloadListener = function (ncode, msg, filename)
	local event = cc.EventCustom:new(FACEDOWNLOAD_LISTENER)
	event.code = ncode
	event.msg = msg
	event.filename = filename

	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end


cc.exports.g_FaceResizeListener = function(oldpath, newpath)
	local event = cc.EventCustom:new(FACERESIZE_LISTENER)
	event.oldpath = oldpath
	event.newpath = newpath

	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end
]]
local SYS_HEADSIZE = 146
function KHead_Sprite.checkData(useritem)
	useritem = useritem or {}
	useritem.dwUserID = useritem.dwUserID or 0
	useritem.dwCustomID = useritem.dwCustomID or 0
	useritem.wFaceID = useritem.wFaceID or 0
	if useritem.wFaceID > 199 then
		useritem.wFaceID = 0
	end
	useritem.cbMemberOrder = useritem.cbMemberOrder or 0

	return useritem
end

function KHead_Sprite:ctor( )
	self.m_spRender = nil
	self.m_downListener = nil
	self.m_resizeListener = nil

	--注册事件
	local function onEvent( event )
		if event == "exit" then
			self:onExit()
		elseif event == "enterTransitionFinish" then
			self:onEnterTransitionFinish()
        end
	end
	self:registerScriptHandler(onEvent)

	self.m_headSize = 146
	self.m_useritem = nil
	self.listener = nil
	self.m_bEnable = false
	--是否头像
	self.m_bFrameEnable = false
	--头像配置
	self.m_tabFrameParam = {}
end

--创建普通玩家头像
function KHead_Sprite:createNormal( useritem ,headSize)
	if nil == useritem then
		--return
	end
	useritem = KHead_Sprite.checkData(useritem)
	local sp = KHead_Sprite.new()
	sp.m_headSize = headSize
	local spRender = sp:initHeadSprite(useritem)
	if nil ~= spRender then
		sp:addChild(spRender)
		local selfSize = sp:getContentSize()
		spRender:setPosition(cc.p(selfSize.width * 0.5, selfSize.height * 0.5))
		return sp
	end
	
	return nil
end

--创建裁剪玩家头像
function KHead_Sprite:createClipHead( useritem, headSize, clippingfile )
	if nil == useritem then
		--return
	end
	useritem = KHead_Sprite.checkData(useritem)

	local sp = KHead_Sprite.new()
	sp.m_headSize = headSize
	local spRender = sp:initHeadSprite(useritem)
	if nil == spRender then
		return nil
	end 
    return sp
	--创建裁剪
	--[[local strClip = "head_mask.png"
	if nil ~= clippingfile then
		strClip = clippingfile
	end
	local clipSp = nil
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strClip)
	if nil ~= frame then
		clipSp = cc.Sprite:createWithSpriteFrame(frame)
	else
		clipSp = cc.Sprite:create(strClip)
	end
	if nil ~= clipSp then
		--裁剪
		local clip = cc.ClippingNode:create()
		clip:setStencil(clipSp)
		clip:setAlphaThreshold(0)
		clip:addChild(spRender)
		local selfSize = sp:getContentSize()
		clip:setPosition(cc.p(selfSize.width * 0.5, selfSize.height * 0.5))
		sp:addChild(clip)
		return sp
	end

	return nil]]
end

function KHead_Sprite:updateHead( useritem )
	if nil == useritem then
		return
	end
	self.m_useritem = useritem

	--判断是否进入防作弊房间
	local bAntiCheat = GlobalUserItem.isAntiCheatValid(useritem.dwUserID)

	--更新头像框
	if self.m_bFrameEnable and false == bAntiCheat then
		local vipIdx = self.m_useritem.cbMemberOrder or 0

		--根据会员等级配置
		local vipIdx = self.m_useritem.cbMemberOrder or 0
		local framestr = string.format("sp_frame_%d_0.png", vipIdx)
		local deScale = 0.72

		local framefile = self.m_tabFrameParam._framefile or framestr
		local scaleRate = self.m_tabFrameParam._scaleRate or deScale
		local zorder = self.m_tabFrameParam._zorder or 1
		self:updateHeadFrame(framefile, scaleRate):setLocalZOrder(zorder)
	end

	if nil ~= useritem.dwCustomID and 0 ~= useritem.dwCustomID and false == bAntiCheat then
		--判断是否有缓存
		local framename = useritem.dwUserID .. "_custom_" .. useritem.dwCustomID .. ".ry"		
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framename)
		if nil ~= frame then
			self:updateHeadByFrame(frame)
			return		
		end		
	end
	--系统头像
	local faceid = useritem.wFaceID or 1
	if true == bAntiCheat then
		faceid = 1
	end
	if faceid >10 then faceid = 10 end
	if faceid <1 then faceid = 1 end
	local str = string.format("public/Face%d.jpg", faceid)
	if not tolua.cast(self.m_spRender,"cc.Sprite") then
		self.m_spRender = cc.Sprite:create(str)
	else
	    local frame = cc.SpriteFrame:create(str,cc.rect(0,0,200,200))
		self.m_spRender:setSpriteFrame(frame)
	end	

	self.m_fScale = self.m_headSize / SYS_HEADSIZE
	self:setScale(self.m_fScale)

	return sp
end

function KHead_Sprite:updateHeadByFrame(frame)
	if nil == self.m_spRender then
		self.m_spRender = cc.Sprite:createWithSpriteFrame(frame)
	else
		self.m_spRender:setSpriteFrame(frame)
	end
	print("width " .. self.m_spRender:getContentSize().width .. " height " .. self.m_spRender:getContentSize().height)
	
	self:setContentSize(self.m_spRender:getContentSize())
	self.m_fScale = self.m_headSize / SYS_HEADSIZE
	self:setScale(self.m_fScale)
end

--允许个人信息弹窗/点击头像触摸事件
function KHead_Sprite:registerInfoPop( bEnable, fun )
	self.m_bEnable = bEnable
	self.m_fun = fun

	if bEnable then
		--触摸事件
		self:registerTouch()
	else
		self:onExit()
	end
end

--头像框
--[[
frameparam = 
{
	--框文件
	_framefile 
	--缩放值
	_scaleRate
	--位置比例
	_posPer{}
	-- z顺序
	_zorder
}
]]
function KHead_Sprite:enableHeadFrame( bEnable, frameparam )
	if nil == self.m_useritem then
		return
	end
	self.m_bFrameEnable = bEnable
	local bAntiCheat = GlobalUserItem.isAntiCheatValid(self.m_useritem.dwUserID)

	if false == bEnable or bAntiCheat then
		if nil ~= self.m_spFrame then
			self.m_spFrame:removeFromParent()
			self.m_spFrame = nil
		end
		return
	end	
	local vipIdx = self.m_useritem.cbMemberOrder or 0

	--根据会员等级配置
	local vipIdx = self.m_useritem.cbMemberOrder or 0
	local framestr = string.format("sp_frame_%d_0.png", vipIdx)
	local deScale = 0.72

	frameparam = frameparam or {}
	self.m_tabFrameParam = frameparam
	local framefile = frameparam._framefile or framestr
	local scaleRate = frameparam._scaleRate or deScale
	local zorder = frameparam._zorder or 1
	self:updateHeadFrame(framefile, scaleRate):setLocalZOrder(zorder)
end

--更新头像框
function KHead_Sprite:updateHeadFrame(framefile, scaleRate)
	local spFrame = nil	
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framefile)
	if nil == frame then
		spFrame = cc.Sprite:create(framefile)
		frame = (spFrame ~= nil) and spFrame:getSpriteFrame() or nil		
	end
	if nil == frame then
		return nil
	end

	if nil == self.m_spFrame then
		local selfSize = self:getContentSize()
		self.m_spFrame = cc.Sprite:createWithSpriteFrame(frame)
		local positionRate = self.m_tabFrameParam._posPer or cc.p(0.5, 0.64)
		self.m_spFrame:setPosition(selfSize.width * positionRate.x, selfSize.height * positionRate.y)
		self:addChild(self.m_spFrame)
	else
		self.m_spFrame:setSpriteFrame(frame)
	end
	self.m_spFrame:setScale(scaleRate)
	return self.m_spFrame
end

function KHead_Sprite:initHeadSprite( useritem )
	self.m_useritem = useritem
	local faceid = useritem.wFaceID
	if faceid >10 then faceid = 10 end
	if faceid <1 then faceid = 1 end
	local str = string.format("public/Face%d.jpg", faceid)
	self.m_spRender = cc.Sprite:create(str)
	self:setContentSize(self.m_spRender:getContentSize())
	self.m_fScale = self.m_headSize / SYS_HEADSIZE
	self:setScale(self.m_fScale)
	return self.m_spRender
end

function KHead_Sprite:getUserHeadSp(args)

end

function KHead_Sprite:haveCacheOrLocalFile(framename, filepath, bmpfile)
	--判断是否有缓存
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framename)
	if nil ~= frame then
		self:updateHeadByFrame(frame)
		return true, self.m_spRender
	else
		--判断是否有本地文件
		local path = filepath
		if cc.FileUtils:getInstance():isFileExist(path) then
			local customframe = nil
			if bmpfile then 
				customframe = createSpriteFrameWithBMPFile(path)
			else
				local sp = cc.Sprite:create(path)
				if nil ~= sp then
					customframe = sp:getSpriteFrame()
				end
			end
			if nil ~= customframe then
				--缓存帧
				local framename = self.m_useritem.dwUserID .. "_custom_" .. self.m_useritem.dwCustomID .. ".ry"    										
				cc.SpriteFrameCache:getInstance():addSpriteFrame(customframe, framename)
				customframe:retain()
				self:updateHeadByFrame(customframe)
				return true, self.m_spRender
			end
		end
	end
	return false
end

--下载头像
function KHead_Sprite:downloadFace(url, path, filename, onDownLoadSuccess)
	local downloader = CurlAsset:createDownloader("g_FaceDownloadListener",url)			
	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end			

	local function eventCustomListener(event)
        if nil ~= event.filename and 0 == event.code then
        	if nil ~= onDownLoadSuccess 
        		and type(onDownLoadSuccess) == "function" 
        		and nil ~= event.filename 
        		and type(event.filename) == "string" then
        		onDownLoadSuccess(event.filename)
        	end        	
        end
	end
	self.m_downListener = cc.EventListenerCustom:create(FACEDOWNLOAD_LISTENER,eventCustomListener)
	self:getEventDispatcher():addEventListenerWithFixedPriority(self.m_downListener, 1)
	downloader:downloadFile(path, filename)
end

function KHead_Sprite:registerTouch( )
	local function onTouchBegan( touch, event )
		return self:isVisible() and self:isAncestorVisible(self) and self.m_bEnable
	end

	local function onTouchEnded( touch, event )
		local pos = touch:getLocation()
        pos = self:convertToNodeSpace(pos)
        local rec = cc.rect(0, 0, self:getContentSize().width, self:getContentSize().height)
        if true == cc.rectContainsPoint(rec, pos) then
            if nil ~= self.m_fun then
            	self.m_fun()
            end
        end        
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function KHead_Sprite:isAncestorVisible( child )
	if nil == child then
		return true
	end
	local parent = child:getParent()
	if nil ~= parent and false == parent:isVisible() then
		return false
	end
	return self:isAncestorVisible(parent)
end

function KHead_Sprite:onExit( )
	if nil ~= self.listener then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListener(self.listener)
		self.listener = nil
	end

	if nil ~= self.m_downListener then
		self:getEventDispatcher():removeEventListener(self.m_downListener)
		self.m_downListener = nil
	end

	if nil ~= self.m_resizeListener then
		self:getEventDispatcher():removeEventListener(self.m_resizeListener)
		self.m_resizeListener = nil
	end
end

function KHead_Sprite:onEnterTransitionFinish()
	if self.m_bEnable and nil == self.listener then
		self:registerTouch()
	end
end

--获取系统头像数量
function KHead_Sprite.getSysHeadCount(  )
	return 72
end


return KHead_Sprite