--
-- Author: zhong
-- Date: 2016-07-07 18:09:11
--
--玩家列表

local ClipText = appdf.req(appdf.CLIENT_SRC .. "Tools.ClipText")
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."Tools.PopupInfoHead")

local UserItem = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.views.layer.userlist.UserItem")

local MUserListLayer = class("MUserListLayer", cc.Layer)
--MUserListLayer.__index = MUserListLayer
MUserListLayer.BT_CLOSE = 1

function MUserListLayer:ctor( )
	--用户列
	self.m_userlist = {}

	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/MUserListLayer.csb", self)

	local sp_bg = csbNode:getChildByName("sp_userlist_bg")
	self.m_spBg = sp_bg
	local content = sp_bg:getChildByName("content")

    self.Text_Zaxin = sp_bg:getChildByName("Text_15")

	--用户列表
	local m_tableView = cc.TableView:create(content:getContentSize())
	m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	m_tableView:setPosition(cc.p(content:getPositionX(),content:getPositionY()))
	m_tableView:setDelegate()
	m_tableView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	sp_bg:addChild(m_tableView)
	self.m_tableView = m_tableView
	content:removeFromParent()

	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end
	local btn = sp_bg:getChildByName("close_btn")
	btn:setTag(MUserListLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	local layout_bg = csbNode:getChildByName("layout_bg")
	layout_bg:setTag(MUserListLayer.BT_CLOSE)
	layout_bg:addTouchEventListener(btnEvent)

	content:removeFromParent()
end

function MUserListLayer:refreshList( userlist )
	self:setVisible(true)
	self.m_userlist = userlist
    if self.m_userlist  then
    local str = string.format("Jogadores online:%d", #self.m_userlist)
    self.Text_Zaxin:setString(str)
    end
    --self.m_userlist={}
	self.m_tableView:reloadData()
end

--tableview
function MUserListLayer.cellSizeForTable( view, idx )
	return UserItem.getSize()
end

function MUserListLayer:numberOfCellsInTableView( view )
	if nil == self.m_userlist then
		return 0
	else

    self._cellCount= math.floor(#self.m_userlist/3)
    
    	    if #self.m_userlist > 0 then
		        if math.mod(#self.m_userlist ,3) ~= 0 then
			        self._cellCount = self._cellCount + 1
		        end
	        end
        return self._cellCount
	end
end

function MUserListLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell()
	
	if nil == self.m_userlist then
		return cell
	end

	local useritem = self.m_userlist[(self._cellCount-idx-1)*3+1]
	local item = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		item = UserItem:create()
		item:setPosition(view:getViewSize().width * 0.5, 0)
		item:setName("user_item_view")
		cell:addChild(item)
	else
		item = cell:getChildByName("user_item_view")
	end

	if nil ~= useritem and nil ~= item then
    local useritemArray={}
    for i=1,3  do

        if self.m_userlist[(self._cellCount-idx-1)*3+i] then
             useritemArray[i]=self.m_userlist[(self._cellCount-idx-1)*3+i]
       end
    end
    
   
		item:refresh(useritemArray, false, 0.5)
	end

	return cell
end
--

function MUserListLayer:onButtonClickedEvent( tag, sender )
	g_ExternalFun.playClickEffect()
	if MUserListLayer.BT_CLOSE == tag then
		self:setVisible(false)
	end
end

return MUserListLayer