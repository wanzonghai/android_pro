
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")
local GameRoomListLayer = class("GameRoomListLayer", RoomListLayer)

local module_pre = "game.yule.egyptSlots.src"
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")

--游戏房间列表
local ANI_PATH = "animation/spine/"
local RES_ID = 120

function GameRoomListLayer:ctor(scene, frameEngine, isQuickStart)
	self._searchPath = cc.FileUtils:getInstance():getSearchPaths()
	cc.FileUtils:getInstance():addSearchPath(device.writablePath.."game/yule/egyptSlots/res")
	GameRoomListLayer.super.ctor(self, scene, isQuickStart)
	self._frameEngine = frameEngine

	-- logo
	local logo = ccui.ImageView:create("roomlist/jxlwbackground.jpg")
	:addTo(self,1000)
	:setPosition(display.cx,display.cy)
	:setTouchEnabled(true)
	logo:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.RemoveSelf:create()))
	display.newSprite("roomlist/jxlwlogo.png")
	:setPosition(display.cx,display.cy)
	:addTo(logo)
	ExternalFun.newAnimationSpine(RES_ID,"jxlw_logoqdlg",ANI_PATH.."jxlw_logoqdlg/")
	:addTo(logo)
	:setPosition(display.cx,display.cy)
	:playAnimation("start",0,false)
	:addAnimation(0,"idle",true)
end

function GameRoomListLayer:onEnterRoom( frameEngine )
	print("自定义房间进入")
	if nil ~= frameEngine and frameEngine:SitDown(G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR) then
        return true
	end
end

--获取开始坐下默认坐下位置
function GameRoomListLayer.getDefaultSit()
	return G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR
end

function GameRoomListLayer:onExit()
    print("GameRoomListLayer onExit")
    cc.exports.roomListLayerGold = nil
    ExternalFun.removeAnimationSpine(RES_ID)
    cc.Director:getInstance():getTextureCache():removeTextureForKey("roomlist/jxlwbackground.jpg")
    cc.FileUtils:getInstance():setSearchPaths(self._searchPath)
end

function GameRoomListLayer:initBg()
    local bg = display.newSprite("roomlist/jxlwbackground.jpg")
    :setPosition(display.cx, display.cy)
    :addTo(self)
end

--初始化顶部UI
function GameRoomListLayer:initTopUI(enterGame)
    local kindID = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
    dump(kindID)
    
    local logoPath = "RoomList/logo/logo_"..kindID..".png"
    --标题
    local gameLogo = display.newSprite(logoPath)
    if nil ~= gameLogo then
        local logoSize = gameLogo:getContentSize()
        local offsetX = logoSize.width > 300 and 10 or 30
        gameLogo:addTo(self)
            :setPosition(display.width - logoSize.width / 2 - offsetX, display.height - logoSize.height / 2 - 10)
    end

    -- 返回按钮
    local backBtn = ccui.Button:create("roomlist/jxlwbtn_return.png", "", "", 0)
	:setPosition(65, display.height - 50)
	:addTo(self)
	:addTouchEventListener(function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            ExternalFun.playCommonButtonClickEffect()
            self:removeFromParent()
        end
    end)
    -- 帮助
    ccui.Button:create("roomlist/jxlwbtn_help.png", "", "", 0)
	:setPosition(180, display.height - 50)
	:addTo(self)
	:addClickEventListener(function(ref)
        ExternalFun.playCommonButtonClickEffect()
        self._searchPathH = cc.FileUtils:getInstance():getSearchPaths()
        cc.FileUtils:getInstance():addSearchPath(device.writablePath.."game/yule/egyptSlots/res")
        self:addChild(HelpLayer:create(),100)
        cc.FileUtils:getInstance():setSearchPaths(self._searchPathH)
    end)
end

--初始化房间按钮
function GameRoomListLayer:initRoomButton()
    local roomCount = #self.m_tabRoomListInfo
    if roomCount > 5 then
        roomCount = 5
    end
    local mgr = 30
    local size = cc.size(277,410)
    local viewSize = cc.size(roomCount*size.width+mgr*(roomCount-1),500)
    local lvView = ccui.ListView:create()
    lvView:setDirection(2)
    lvView:setGravity(5)
    lvView:setItemsMargin(mgr)
    lvView:setPosition(display.cx-viewSize.width/2,120)
    lvView:addTo(self)
  --  lvView:setBackGroundColorType(1)
    lvView:setClippingEnabled(false)
   -- lvView:setBackGroundColor(cc.c3b(0,0,0))
    lvView:setBounceEnabled(true)
    lvView:setScrollBarEnabled(false)
    if viewSize.width > display.width then
        lvView:setPosition(20,120)
    end
    if viewSize.width > display.width-50 then
        viewSize.width = display.width-50
    end
    lvView:setContentSize(viewSize)

	-- local enterGame = self._scene:getEnterGameInfo()
    for i = 1, roomCount do
        local iteminfo = self.m_tabRoomListInfo[i]
        local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
        wLv = (wLv ~= 0) and wLv or 1
        local roomLv = "jxlw_tiyanxuanchang"
        if wLv == 2 then
            roomLv = "jxlw_chujixuanchang"
        elseif wLv == 3 then
            roomLv = "jxlw_putongxuanchang"
        elseif wLv == 4 then
			roomLv = "jxlw_zhongjichang"
		elseif wLv == 5 then
            roomLv = "jxlw_gaojixuanchang"
        end

		local ix = wLv-1
        local btn = ccui.Button:create("roomlist/jxlwbtn_"..ix..".png","roomlist/jxlwbtn_"..ix..".png","")
        :addTo(lvView)
        btn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                btn:setScale(1.01)
                return
            elseif eventType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                if not iteminfo then
		            return
	            end
	            GlobalUserItem.nCurRoomIndex = iteminfo._nRoomIndex
	            GlobalUserItem.bPrivateRoom = (iteminfo.wServerType == G_NetCmd.GAME_GENRE_PERSONAL)
	            self:getParent():onStartGame()
            end
            btn:setScale(1.0)
            return
        end)
        btn:setScale9Enabled(true)
        btn:setContentSize(size.width,size.height)
        ExternalFun.newAnimationSpine(RES_ID,roomLv,ANI_PATH)
        :addTo(btn)
        :playAnimation("animation",0,true)
		:setPosition(size.width/2,size.height/2+70)
		ExternalFun.newAnimationSpine(RES_ID,"jxlw_xuanchanglg",ANI_PATH)
        :addTo(btn)
        :playAnimation("animation",0,true)
        :setPosition(size.width/2,size.height/2)

        --状态
        local state = 1
        local stateFile = string.format('roomlist/jxlwimage_%s.png', state)
		local roomState = display.newSprite(stateFile)
		:setPosition(size.width/2 + 60, 75)
		:addTo(btn)

        --准入金额
        local enterScore = iteminfo.lEnterScore or 0
        if iteminfo.wServerType == 8 then
            -- 体验场
            enterScore = 0
        end
        
        if enterScore <=0 then
            local minGold = display.newSprite('roomlist/jxlwimage_free.png')
			:setPosition(size.width/2 - 35, 75)
			:addTo(btn)
        else
            if enterScore >= 10000 then
                enterScore = math.ceil(enterScore/10000)
                enterScore = enterScore.."万"
            end
        
            local enterStr = display.newSprite('roomlist/jxlwimage_threshold.png')
			:addTo(btn)
			:setAnchorPoint(cc.p(0,0.5))
			:setPosition(size.width/2 - 90, 75)
			local enterStrSize = enterStr:getContentSize()
			local label = ccui.Text:create(enterScore,"",26)
			:addTo(btn)
			:setAnchorPoint(cc.p(0,0.5))
			:setPosition(size.width/2 - 45, 75)
			:setTextColor(cc.c4b(255,255,255,255))
        end
    end

end

--初始化底部UI
function GameRoomListLayer:initBottomUI()
    local bottomZorder = 10
    self.bottomLayer = display.newLayer()
    :setPosition(0, 0)
    :addTo(self, bottomZorder)

    --底背景
    local bottomBg = display.newSprite('roomlist/jxlwbottom_panel.png')
    :setAnchorPoint(0.5, 0)
    :setPosition(display.cx, 0)
    :addTo(self.bottomLayer)
    
    --快速开始按钮
    local function quickCallBack()
        print('快速开始')
        self:getParent():quickStartNew()
    end
  --  local fastButton = ExternalFun.addEffectNodeButton(self.bottomLayer, 'animation/spine/', 'jxlw_quickstart', cc.size(265, 75), cc.p(display.width+130, 37), cc.p(-160, 0), quickCallBack)
--    ExternalFun.createDebugBox(fastButton)
	local btn = ccui.Button:create("","","")
    :addTo(self.bottomLayer)
    btn:setScale9Enabled(true)
	btn:setContentSize(265,100)
	btn:setPosition(display.width-130, 37)
	btn:addClickEventListener(function(sender)
		quickCallBack()
	end)
	ExternalFun.newAnimationSpine(RES_ID,"jxlw_quickstart",ANI_PATH.."jxlw_quickstart/")
    :addTo(btn)
	:playAnimation("animation",0,true)
	:setPosition(260,10)

    --头像
    local headBg = display.newSprite('roomlist/jxlwframe_head.png')
    :setPosition(100 - 26, 100 - 50)
    :addTo(self.bottomLayer)
    local headBgSize = headBg:getContentSize()
    local head = ExternalFun.getClipHeadImage(GlobalUserItem, 'plaza/Hall_ZJM_Head_Bg_Boy.png')
	if not tolua.isnull(head) then
        head:setPosition(headBgSize.width/2-5, headBgSize.height/2+3)
        head:addTo(headBg)
        head:setScale(0.7)
	end

    --昵称
    local nameStr = GlobalUserItem.szNickName
    nameStr = ExternalFun.subStringByWidth(nameStr, 180, '..', 26, "fonts/round_body.ttf")

    local nickName = cc.Label:createWithTTF(nameStr, "fonts/round_body.ttf", 26)
    :setAnchorPoint(cc.p(0,0.5))
    :setPosition(100 + 20, 28)
    :setTextColor(cc.c4b(207,190,111,255))
    :addTo(self.bottomLayer)


    --金豆背景
    local of = 5
    local beanBg = display.newSprite('roomlist/jxlwimage_coin_bg.png')
    :setPosition(458, 27+of)
    :addTo(self.bottomLayer)

    local beanBgSize = beanBg:getContentSize()
    --金豆
    -- local jsonName = 'RoomList/spine/GoldBean/GoldBean.json'
    -- local atlasName = 'RoomList/spine/GoldBean/GoldBean.atlas'
    -- local beanNode = sp.SkeletonAnimation:create(jsonName, atlasName, 0.7)
    -- :setPosition(22, beanBgSize.height/2+3)
    -- :addTo(beanBg)
	-- :setAnimation(0, "animation", true)
	display.newSprite("roomlist/jxlwimage_coin.png")
	:setPosition(30,beanBgSize.height/2)
	:addTo(beanBg)

    --金豆数
    local str = string.formatNumberThousands(GlobalUserItem.lUserScore,true, ':')
    self.userScore = cc.LabelAtlas:_create(str, 'plaza/font_bean.png', 17, 26, string.byte('0'))
    :setAnchorPoint(cc.p(0.5, 0.5))
	:setPosition(beanBgSize.width/2, beanBgSize.height/2-1)
	:addTo(beanBg)
    :setScale(0.7)
    cc.exports.roomListLayerGold = function()
        local serverKind = G_GameFrame:getServerKind()
        self.userScore:setString(g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.standard,serverKind))
    end

    --增加金豆按钮
    local btnBean = ccui.Button:create('roomlist/jxlwbtn_shop.png', '', '')
    :addTo(beanBg)
    :setPosition(beanBgSize.width - 37, beanBgSize.height/2+1)
    :addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.ended then
            ExternalFun.playCommonButtonClickEffect()
            self:getParent():addBankLayer()
        end
    end)
end

return GameRoomListLayer