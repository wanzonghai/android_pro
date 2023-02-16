--
-- Author: zhouweixiang
-- Date: 2016-11-25 10:10:42
--
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameRoomListLayer = class("GameRoomListLayer", RoomListLayer)
--游戏房间列表
local PRELOAD = require("game.yule.mllegend.src.views.layer.PreLoading")
GameRoomListLayer.RES_PATH = "game/yule/mllegend/res/"
GameRoomListLayer.BT_TIYANCHANG   = 1
GameRoomListLayer.BT_PUTONGCHANG  = 2
GameRoomListLayer.BT_GAOJICHANG   = 3
GameRoomListLayer._bDuizhan = false;
--GameRoomListLayer._POS = 
--	{
--		{cc.p(876,350)},	--1
--		{cc.p(865,485),cc.p(940,285)}, --2
--		{cc.p(674,545),cc.p(837,364),cc.p(1008,187)}, -- 3
--		{cc.p(647,482),cc.p(1096,482),cc.p(614,267),cc.p(1067,267)}, -- 4
--		{cc.p(698,554),cc.p(665,360),cc.p(628,163),cc.p(1113,450),cc.p(1082,245)}, -- 5
--		{cc.p(14,180),cc.p(170,220),cc.p(324,180),cc.p(324,19),cc.p(170,-26),cc.p(14,19)}, --6
--	}
GameRoomListLayer._POS = 
	{
		{cc.p(667,400)},	--1
		{cc.p(440,400),cc.p(867,400)}, --2
		{cc.p(440,460),cc.p(867,460),cc.p(667,220)}, -- 3
		{cc.p(440,460),cc.p(867,460),cc.p(440,220),cc.p(867,220)}, -- 4
		{cc.p(250,460),cc.p(667,460),cc.p(1090,460),cc.p(440,220),cc.p(867,220)}, -- 5
		{cc.p(250,460),cc.p(667,460),cc.p(1090,460),cc.p(250,220),cc.p(667,220),cc.p(1090,220)}, --6
	}
GameRoomListLayer._LevelName = 
{
    [0] = "体验房",
    [1] = "初级房",
    [2] = "普通房",
    [3] = "中级房",
    [4] = "高级房",
    [5] = "",
    [9] = "新手房",
    [10] = "体验房",
    [11] = "初级房",
    [12] = "普通房",
    [13] = "中级房",
    [14] = "高级房",
}
-- 进入场景而且过渡动画结束时候触发。
function GameRoomListLayer:onEnterTransitionFinish()
    return self
end
-- 退出场景而且开始过渡动画时候触发
function GameRoomListLayer:onExitTransitionStart()
    return self
end
function GameRoomListLayer:onSceneAniFinish()

end
function GameRoomListLayer:onExit()
    
   
end
function GameRoomListLayer:ctor(scene, frameEngine, isQuickStart)
	--GameRoomListLayer.super.ctor(self, scene, isQuickStart)
    ExternalFun.registerNodeEvent(self)
	self._frameEngine = frameEngine
    self:playGamebgMusic()
    self._scene = scene

    self.m_bIsQuickStart = isQuickStart or false
    
    if true == self.m_bIsQuickStart then
		self:stopAllActions()
		GlobalUserItem.nCurRoomIndex = 1
		self:onStartGame()
	end
    
    display.newSprite(GameRoomListLayer.RES_PATH.."roomlist/hall_bg.png")
         :move(667, 375)
         :addTo(self)

--    local load_bg = display.newSprite(GameRoomListLayer.RES_PATH .. "roomlist/meinv.png")
--    load_bg:move(180, 294)
--    load_bg:addTo(self)

    self.m_tabRoomListInfo = {}
	for k,v in pairs(GlobalUserItem.roomlist) do
		if tonumber(v[1]) == GlobalUserItem.nCurGameKind then
			local listinfo = v[2]
			if type(listinfo) ~= "table" then
				break
			end
			local normalList = {}
			for k,v in pairs(listinfo) do
				if v.wServerType ~= G_NetCmd.GAME_GENRE_PERSONAL then
					table.insert( normalList, v)
				end
			end
			self.m_tabRoomListInfo = normalList
			break
		end
	end
    self:onRoomListInfo();
    --dump(self.m_tabRoomListInfo,100)
    --self:getRoomListButton()
    self:getRoomList()
end

function GameRoomListLayer:getRoomListButton()
    if #self.m_tabRoomListInfo == 0 then
       return
    end
    local btcallback = function (ref, type)
		if type == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(ref:getTag(),ref)
		end
	end
    local pos =GameRoomListLayer._POS[#self.m_tabRoomListInfo]
    for i = 1,#self.m_tabRoomListInfo do
        local iteminfo = self.m_tabRoomListInfo[i]
        local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
		--wLv = (bit:_and(ylAll.SR_ALLOW_AVERT_CHEAT_MODE, rule) ~= 0) and 10 or iteminfo.wServerLevel
		--wLv =  wLv or 0
        wLv = wLv - 9
        --dump(iteminfo)
        if wLv == 0 then
            wLv = 1
        end
        local lEnterScore = (iteminfo == nil and "0" or iteminfo.lEnterScore)
		-- local enterGame = self._scene:getEnterGameInfo()
        local path = GameRoomListLayer.RES_PATH.."roomlist/sub_game_1_" .. wLv .. ".png"
       
        local button = ccui.Button:create(path)        
        button:setPosition(pos[i])
        button:addTo(self)
        button:setTag(i)
        button:setScale(0.85)
	    button:addTouchEventListener(btcallback)
        
        button:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(0.3,cc.p(-20,0))),
                                          cc.EaseSineOut:create(cc.MoveBy:create(0.3,cc.p(20,0)))))
        local enterScore
        if wLv ~= 0 then
           enterScore = "准入："..ExternalFun.formatScoreTextl(iteminfo.lEnterScore)
        else
           enterScore = "体验场"
        end
         cc.Label:createWithTTF(enterScore,"fonts/round_body.ttf",36)
           :move(220,60)
           :setAnchorPoint(0.5,0.5)
           --:setTextColor(cc.c3b(255,165,0))
           :addTo(button)

    end
    
end

function GameRoomListLayer:onEnterRoom( frameEngine )
	print("自定义房间进入")
	if nil ~= frameEngine and frameEngine:SitDown(G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR) then
        return true
	end
end

function GameRoomListLayer:onButtonClickedEvent(tag,ref)
    local roominfo = self.m_tabRoomListInfo[tag]
    if not roominfo then
        return
    end
    GlobalUserItem.roomTypeNum = roominfo.wServerLevel
    GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
    GlobalUserItem.bPrivateRoom =(roominfo.wServerType == G_NetCmd.GAME_GENRE_PERSONAL)
    if self._scene:roomEnterCheck() then
        self:onStartGame()
    end

end

function GameRoomListLayer:onStartGame(index)
	local iteminfo = GlobalUserItem.GetRoomInfo(index)
	if iteminfo ~= nil then
        PRELOAD.GameLoadingView()
		self._scene:onStartGame(index)
	end
end

function GameRoomListLayer:AniExit()

end

function GameRoomListLayer:AniExit_other()

end

--获取开始坐下默认坐下位置
function GameRoomListLayer.getDefaultSit()
	return G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR
end

function GameRoomListLayer:playGamebgMusic()
    if GlobalUserItem.bVoiceAble then
        -- 播放背景音乐
        AudioEngine.playMusic(GameRoomListLayer.RES_PATH .. "sound_res/BG.wav", true)
    end
end
function GameRoomListLayer:onRoomListInfo()
    
    function diff(tab,idx)
        if tab == nil then 
            return false
        end

        for i=1,#tab do
            if idx == tab[i] then 
                return false
            end
        end
        return true
    end    
    
    self.m_tabRoomList = {}
    self.m_tabRoomlevel = {}

    for i=1,#self.m_tabRoomListInfo do 
        local roominfo = self.m_tabRoomListInfo[i]
        local index = (roominfo == nil and 0 or roominfo.wServerLevel)
        if diff(self.m_tabRoomlevel,index) then 
            table.insert(self.m_tabRoomlevel,index)
        end
    end
    --dump(self.m_tabRoomlevel)
    for i=1,#self.m_tabRoomListInfo do 
        local roominfo = self.m_tabRoomListInfo[i]
        local index = (roominfo == nil and 0 or roominfo.wServerLevel)
        for j=1,#self.m_tabRoomlevel do 
            if index == self.m_tabRoomlevel[j] then 
                if self.m_tabRoomList[j] == nil then 
                    self.m_tabRoomList[j] = {}                
                end
                self.m_tabRoomList[j][#self.m_tabRoomList[j]+1] = roominfo
            end
        end
    end

    --dump(self.m_tabRoomList,100)

end

function GameRoomListLayer:getRoomList()
    if #self.m_tabRoomList == 0 then
       return
    end
    local btcallback = function (ref, type)
		if type == ccui.TouchEventType.ended then
			self:onButtonEvent(ref:getTag(),ref)
		end
	end
    local pos =GameRoomListLayer._POS[#self.m_tabRoomList]
    for i = 1,#self.m_tabRoomList do
        local iteminfo = self.m_tabRoomList[i][1]
        if iteminfo == nil then 
            return 
        end
        local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
		--wLv = (bit:_and(ylAll.SR_ALLOW_AVERT_CHEAT_MODE, rule) ~= 0) and 10 or iteminfo.wServerLevel
		--wLv =  wLv or 0
        wLv = wLv - 9
        --dump(iteminfo)
        if wLv == 0 then
            wLv = 1
        end
        local lEnterScore = (iteminfo == nil and "0" or iteminfo.lEnterScore)
		-- local enterGame = self._scene:getEnterGameInfo()
        local path = GameRoomListLayer.RES_PATH.."roomlist/sub_game_1_" .. wLv .. ".png"
       
        local button = ccui.Button:create(path)        
        button:setPosition(pos[i])
        button:addTo(self)
        button:setTag(i)
        button:setScale(0.85)
	    button:addTouchEventListener(btcallback)
        button:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(0.3,cc.p(-20,0))),
                                          cc.EaseSineOut:create(cc.MoveBy:create(0.3,cc.p(20,0)))))
        local enterScore
        if wLv ~= 0 then
           enterScore = "准入："..ExternalFun.formatScoreTextl(iteminfo.lEnterScore)
        else
           enterScore = "体验场"
        end
        local label = cc.Label:createWithTTF(enterScore, "fonts/round_body.ttf", 36)
        label:move(220, 60)
        label:setAnchorPoint(0.5, 0.5)
        -- label:setTextColor(cc.c3b(255,165,0))
        label:addTo(button)

    end
end

function GameRoomListLayer:onButtonEvent(tag,ref)
    
    if self.m_tabRoomList[tag] == nil then 
        return 
    end

    if #self.m_tabRoomList[tag]~=1 then 
        self:createRoomList(tag)
        return 
    end

    local roominfo = self.m_tabRoomList[tag][1]
    if not roominfo then
        return
    end


    GlobalUserItem.roomTypeNum = roominfo.wServerLevel
    GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
    GlobalUserItem.bPrivateRoom =(roominfo.wServerType == G_NetCmd.GAME_GENRE_PERSONAL)
    if self._scene:roomEnterCheck() then
        if roominfo.lEnterScore> GlobalUserItem.lUserScore then 
            showToast(string.format("抱歉，您的游戏成绩低于当前游戏房间的最低进入成绩%d，不能进入当前游戏房间！",roominfo.lEnterScore))--抱歉，您的游戏成绩低于当前游戏房间的最低进入成绩1000，不能进入当前游戏房间！
            return 
        end
        self:onStartGame()
    end
end

function GameRoomListLayer:createRoomList(tag)
    local this = self
    local RoomList = self.m_tabRoomList[tag]

    function onEnterGame(idx, ref)
        if RoomList[idx] == nil then
            return
        end
        local roominfo = RoomList[idx]
        GlobalUserItem.roomTypeNum = roominfo.wServerLevel
        GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
        GlobalUserItem.bPrivateRoom =(roominfo.wServerType == G_NetCmd.GAME_GENRE_PERSONAL)
        if this._scene:roomEnterCheck() then
            if roominfo.lEnterScore > GlobalUserItem.lUserScore then
                -- 抱歉，您的游戏分数低于当前游戏房间的最低进入分数%d，您无法进入当前游戏房间
                showToast(string.format("Sorry, your game score is lower than the minimum entry score %d of the current game room, and you cannot enter the current game room!", roominfo.lEnterScore))
                return
            end
            this:onStartGame()
        end
    end

    function tableCellTouched(view, cell)

    end

    function cellSizeForTable(view, idx)
        return 630,140
    end

    function tableCellAtIndex(view, idx)
        local cell = view:dequeueCell()

        local btcallback = function(ref, type)
            if type == ccui.TouchEventType.ended then
                if view:isTouchMoved() then
                    return
                end
                onEnterGame(ref:getTag(),ref)
            else
                ref:setSwallowTouches(false)
            end
        end


        if cell == nil then
            cell = cc.TableViewCell:new()
        end

        local index = idx+1

        for i=1,2 do 
            local iteminfo = RoomList[idx*2+i]
            if iteminfo then 
                local wLv =(iteminfo == nil and 0 or iteminfo.wServerLevel)
                -- wLv = (bit:_and(ylAll.SR_ALLOW_AVERT_CHEAT_MODE, rule) ~= 0) and 10 or iteminfo.wServerLevel
                -- wLv =  wLv or 0
                wLv = wLv - 9
                -- dump(iteminfo)
                if wLv == 0 then
                    wLv = 1
                end
                local lEnterScore =(iteminfo == nil and "0" or iteminfo.lEnterScore)
                local path = "RoomList/room_list.png"

                local button = ccui.Button:create(path,path,path)
                button:setPosition(cc.p(630/2*(i-1)+630/4,140/2))
                button:addTo(cell)
                button:setTag(idx*2+i)
                button:addTouchEventListener(btcallback)
                local enterScore
                if wLv ~= 0 then
                    enterScore =  ExternalFun.formatScoreTextl(iteminfo.lEnterScore)--"准入："
                else
                    enterScore = "体验场"
                end
--                local label = cc.Label:createWithTTF(enterScore, "fonts/round_body.ttf", 20)
--                label:move(150, 50)
--                label:setAnchorPoint(0.5, 0.5)
--                -- label:setTextColor(cc.c3b(255,165,0))
--                label:addTo(button)
                local bg = cc.Sprite:create("RoomList/text3.png")
                bg:move(150, 40)
                bg:addTo(button)
                local label = cc.Label:createWithTTF(GameRoomListLayer._LevelName[iteminfo.wServerLevel] ..idx*2+i .." ("..enterScore .. "以上)" , "fonts/round_body.ttf", 26)
                label:move(150, 80)
                label:setAnchorPoint(0.5, 0.5)
                -- label:setTextColor(cc.c3b(255,165,0))
                label:addTo(button)

            end

        end



        if info == nil then
            return cell;
        end

        return cell
    end

    function numberOfCellsInTableView(view)
        return math.ceil((#RoomList)/2)
    end


    local Panel = ccui.Layout:create()
    Panel:addTo(self,3)
    Panel:setPosition(cc.p(0,0))
    Panel:setSize(cc.size(ylAll.WIDTH,ylAll.HEIGHT))
    Panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
    Panel:setClippingEnabled(false)
    Panel:setTouchEnabled(true)

    local bg = cc.Sprite:create("RoomList/room_bg.png")
    bg:addTo(Panel)
    bg:setPosition(cc.p(ylAll.WIDTH/2,ylAll.HEIGHT/2-50))

    local title = cc.Sprite:create("RoomList/room_title.png")
    title:addTo(Panel)
    title:setPosition(cc.p(ylAll.WIDTH/2,630-50))

    local button = ccui.Button:create("RoomList/room_close.png")
    button:setPosition(cc.p(1000, 635-50))
    button:addTo(Panel)
    button:addTouchEventListener( function(ref, type)
        if type == ccui.TouchEventType.ended then
            Panel:removeFromParent()
        end
    end )



    local _listView = cc.TableView:create( cc.size(630,450))
    _listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _listView:setPosition(cc.p(350,140-50))
    _listView:setAnchorPoint(0,0)
    _listView:setDelegate()
    _listView:addTo(Panel)
    _listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _listView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    _listView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    _listView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    _listView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _listView:reloadData()

end


return GameRoomListLayer