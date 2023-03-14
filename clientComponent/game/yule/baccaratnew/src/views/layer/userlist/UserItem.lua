--
-- Author: zhong
-- Date: 2016-07-07 18:55:48
--

local ClipText = appdf.req(appdf.CLIENT_SRC .. "Tools.ClipText")
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."Tools.PopupInfoHead")
local HeadSprite = appdf.req(appdf.CLIENT_SRC .. "Tools.HeadSpriteNew")
local UserItem = class("UserItem", cc.Node)

function UserItem:ctor()
	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/BrnnOnlineItem.csb", self)
	self.m_csbNode = csbNode

	--头像
	--local tmp = csbNode:getChildByName("sp_head")	
--	self.m_headSize = tmp:getContentSize().width
--	tmp:removeFromParent()

	--昵称
	--tmp = csbNode:getChildByName("text_name")
	--local clipText = ClipText:createClipText(tmp:getContentSize(), "")
	--clipText:setTextFontSize(30)
	--clipText:setAnchorPoint(tmp:getAnchorPoint())
	--clipText:setPosition(tmp:getPosition())
	--csbNode:addChild(clipText)
	--tmp:removeFromParent()
	--self.m_clipText = clipText

	--抢庄标志
	--local rob = csbNode:getChildByName("sp_rob")
	--rob:setVisible(false)
	--self.m_spRob = rob

	--游戏币1
	--local coin = csbNode:getChildByName("text_coin")
--	coin:setString("")
	--self.m_textCoin = coin
end

function UserItem.getSize( )
	return 650,200
end
local function chsize(char)
     if not char then
         print("not char")
         return 0
     elseif char > 240 then
         return 4
     elseif char > 225 then
         return 3
     elseif char > 192 then
         return 2
     else
         return 1
     end
 end
function utf8len(str)
     local len = 0
     local currentIndex = 1
     while currentIndex <= #str do
         local char = string.byte(str, currentIndex)
         currentIndex = currentIndex + chsize(char)
         len = len +1
     end
     return len
 end

 function utf8sub(str, startChar, numChars)
    local startIndex = 1
     while startChar > 1 do
        local char = string.byte(str, startIndex)
         startIndex = startIndex + chsize(char)
        startChar = startChar - 1
     end
 
     local currentIndex = startIndex
 
     while numChars > 0 and currentIndex <= #str do
         local char = string.byte(str, currentIndex)
         currentIndex = currentIndex + chsize(char)
         numChars = numChars -1
     end
     return str:sub(startIndex, currentIndex - 1)
 end
--type == 1表示上庄申请列表
function UserItem:refresh( useritemArray,var_bRob, yPer, showtype)
	if nil == useritemArray then
		return
	end

  --[[  if true then
        return 
    end]]
    local itemCount = #useritemArray 
     for i=1,itemCount  do

     if i>3 then
         break
     end
          local FileNode_ =  self.m_csbNode:getChildByName("FileNode_"..i)	
          FileNode_:setVisible(true)	
          local txtName_tf = FileNode_:getChildByName("txtName_tf")	
          
            local str = useritemArray[i].szNickName
                            if utf8len(str) >8 then
		                        str = utf8sub(str,1,8) .. "..."
	                          end
          	txtName_tf:setString(str)

             local txtScore_tf = FileNode_:getChildByName("txtScore_tf")	
          

            local coin = 0
	        if nil ~= useritemArray[i].lScore then
		        coin = useritemArray[i].lScore
	        end
	        local str = g_ExternalFun.formatScoreKMBT(coin)

          	txtScore_tf:setString(str)
           local headImage_1 = FileNode_:getChildByName("Image_1")
             headImage_1:removeChildByTag(200, true)
              local phead = PopupInfoHead:createClipHead(useritemArray[i], 65)
                phead:setPosition(62-20+4, 61+5)
                phead:setTag(200)
                headImage_1:addChild(phead)
            

     end
     for i = (itemCount+1)  ,3 do
        local FileNode_ =  self.m_csbNode:getChildByName("FileNode_"..i)
        
        FileNode_:setVisible(false)	
     end
     if true then
        return 

     end

	local showtype = showtype
	showtype = nil == showtype and 0 or 1
	--更新头像
	if nil ~= self.m_head and nil ~= self.m_head:getParent() then
		self.m_head:removeFromParent()
		self.m_head = nil
	end
	self.m_head = PopupInfoHead:createNormal(useritem, self.m_headSize)
	self.m_head:setPosition(-217,37)
	self.m_csbNode:addChild(self.m_head)
	local showpos = cc.p(360,320)
	local anchor = cc.p(1.0, yPer)
	if showtype == 1 then
		showpos = cc.p(10, 280)
	end
	self.m_head:enableInfoPop(true, showpos, anchor)

	--更新昵称
	local szNick = ""
	if nil ~= useritem.szNickName then
		szNick = useritem.szNickName
	end
	self.m_clipText:setString(szNick)

	--更新抢庄标志
	local bRob = var_bRob or false
	self.m_spRob:setVisible(bRob)

	--更新游戏币
	local coin = 0
	if nil ~= useritem.lScore then
		coin = useritem.lScore
	end
	local str = g_ExternalFun.formatScoreText(coin)
	self.m_textCoin:setString(str)
end

return UserItem