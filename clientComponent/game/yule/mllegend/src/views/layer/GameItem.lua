local ExternalFun = g_ExternalFun --require(appdf.EXTERNAL_SRC .. "ExternalFun")

local cmd = "game.yule.mllegend.src.models.CMD_Game"
local GameLogic = appdf.req("game.yule.mllegend.src.models.GameLogic")
local emItemState = 
{
	"STATE_NORMAL",		--正常
	"STATE_SELECT",		--中奖
	"STATE_GREY",		--变灰
    "STATE_RUN"
}
local ITEM_STATE = ExternalFun.declarEnumWithTable(0, emItemState);

local GameItem = class("GameItem",cc.ClippingRectangleNode)


GameItem.GAME_IMG_TAG = 100

GameItem.WIDTH = 183
GameItem.HEIGHT = 183

GameItem.TEXTUREPLIST = 
{
    "ml_icon_1.png",
    "ml_icon_2.png",
    "ml_icon_3.png",
    "ml_icon_4.png",
    "ml_icon_5.png",
    "ml_icon_6.png",
    "ml_icon_7.png",
    "ml_icon_8.png",
    "ml_icon_9.png",
    "ml_icon_10.png",
    "ml_icon_11.png",
    "ml_icon_12.png",

}
GameItem.TEXTURERUNPLIST = 
{
    "mh_icon_1.png",
    "mh_icon_2.png",
    "mh_icon_3.png",
    "mh_icon_4.png",
    "mh_icon_5.png",
    "mh_icon_6.png",
    "mh_icon_7.png",
    "mh_icon_8.png",
    "mh_icon_9.png",
    "mh_icon_10.png",
    "mh_icon_11.png",
    "mh_icon_12.png",
}

function GameItem:ctor(  )
    
end

function GameItem:onExit()
    
    if self.m_ani then 
        ExternalFun.SAFE_RELEASE(self.m_ani)
        self.m_ani = nil
    end
end
--初始化
function GameItem:created( nType )
	self.m_bIsEnd = false
    self.m_State = ITEM_STATE.STATE_NORMAL
	self.m_nType = -1
	self.m_pSprite = nil
    self.m_pAni = nil;
    self.m_ani = nil
	self:initNotice()
	self:setItemType(nType)
    self:initWin()
end

function GameItem:initNotice()
	self:setClippingRegion(cc.rect(0,0,GameItem.WIDTH,GameItem.HEIGHT))
	self:setClippingEnabled(true)
end

function GameItem:setItemType(nType,state)
	self.m_nType = nType
    
    
    local feame = nil

--    if state == ITEM_STATE.STATE_RUN then
--        feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTURERUNPLIST[self.m_nType])
--    else 
        feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTUREPLIST[self.m_nType])    
    --end



    if not feame then
        print(" not feame",self.m_nType)
        return
    end

    if self.m_pSprite then
        self.m_pSprite:setSpriteFrame(feame)
        self.m_pSprite:setVisible(true)
        self.m_pSprite:setOpacity(255)
    else
        self.m_pSprite = cc.Sprite:create()
        self.m_pSprite:setSpriteFrame(feame)
        self:addChild(self.m_pSprite, 10)
        self.m_pSprite:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
        self.m_pSprite:setAnchorPoint(0.5,0.5)
    end

    if not self.m_pAni then
        --local Ani = ExternalFun.loadTimeLine(csbList[i])
        --local csb = cc.CSLoader:createNode(csbList[i])
        --self.m_ani = ExternalFun.loadTimeLine("game_csb/baozha.csb")
        self.m_pAni = cc.CSLoader:createNode("game_csb/baozha.csb")
        self:addChild(self.m_pAni, 11)
        self.m_pAni:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
        self.m_pAni:setAnchorPoint(0.5,0.5)
    end

    if not self.m_ani then 
        self.m_ani = ExternalFun.loadTimeLine("game_csb/baozha.csb")
        ExternalFun.SAFE_RETAIN(self.m_ani)
    end


    self.m_pAni:setVisible(false)
    self.m_pAni:stopAllActions()
    --self.m_pSprite:stopAllActions()
end

function GameItem:getItemType( )
	return self.m_nType
end

function GameItem:stopAllItemAction(  )
	self.m_bIsEnd = true
	if self.m_pSprite ~= nil then
		--self.m_pSprite:stopAllActions()
        self.m_pSprite:setOpacity(255)
	else
		print("不存在这个GameItem")
	end
	self:setState(ITEM_STATE.STATE_NORMAL)
	self:stopAllActions()
end

function GameItem:initWin()
    
    
end

function GameItem:setWin(bFree)
    local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTUREPLIST[self.m_nType])

    if not feame then
        print(" not feame",self.m_nType)
        return
    end

    if not self.m_pSprite then        
        self.m_pSprite = cc.Sprite:create()
        self.m_pSprite:setSpriteFrame(feame)
        self:addChild(self.m_pSprite, 10)
        self.m_pSprite:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
        self.m_pSprite:setAnchorPoint(0.5,0.5)
    end
    --self.m_pSprite:stopAllActions()
    self.m_pSprite:setOpacity(255)

    self.m_ani:gotoFrameAndPlay(0,false)
    self.m_pAni:runAction(self.m_ani)
    self.m_pAni:setVisible(true)

    if bFree ~= true then 
        self.m_pSprite:runAction(cc.FadeOut:create(0.4))
    end

--  local seq=cc.Sequence:create(ani,cc.CallFunc:create(callback))
--  local ani = cc.Animate:create(anicache)
--  self.m_pSprite:runAction(ani)

end


function GameItem:setTagLabel(tag)
--    local label = cc.Label:createWithTTF(tag, "fonts/round_body.ttf", 100)
--    label:addTo(self,20)
--    label:setTextColor(cc.RED)
--    label:move(GameItem.WIDTH/2,GameItem.HEIGHT/2)
end

function GameItem:setState( nState )
	self.m_bIsEnd = true
    
    if self.m_State == nState then
        return 
    else 
        self.m_State = nState
    end

    

	if nState == ITEM_STATE.STATE_NORMAL then
		--正常
        local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTUREPLIST[self.m_nType])
        if not feame then
            return
        end
	    if self.m_pSprite then
			self.m_pSprite:setSpriteFrame(feame)
            self.m_pSprite:setOpacity(255)
		else
			self.m_pSprite = cc.Sprite:create()
			self.m_pSprite:setSpriteFrame(feame)
            self:addChild(self.m_pSprite,10)
            self.m_pSprite:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
            self.m_pSprite:setAnchorPoint(0.5,0.5)
	    end

	elseif	nState == ITEM_STATE.STATE_SELECT then
		--播放动画


	elseif	nState == ITEM_STATE.STATE_GREY then
		--灰色纹理

        local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTUREPLIST[self.m_nType])
        if not feame then
            return
        end

        if self.m_pSprite then
			self.m_pSprite:setSpriteFrame(feame)
            self.m_pSprite:setOpacity(100)
		else
			self.m_pSprite = cc.Sprite:create()
			self.m_pSprite:setSpriteFrame(feame)
            self:addChild(self.m_pSprite,10)
            self.m_pSprite:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
            self.m_pSprite:setAnchorPoint(0.5,0.5)
	    end

       
    elseif	nState == ITEM_STATE.STATE_RUN then
        local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(GameItem.TEXTURERUNPLIST[self.m_nType])
        if not feame then
            return
        end
        if self.m_pSprite then
			self.m_pSprite:setSpriteFrame(feame)
		else
			self.m_pSprite = cc.Sprite:create()
			self.m_pSprite:setSpriteFrame(feame)
            self:addChild(self.m_pSprite,10)
            self.m_pSprite:move(cc.p(GameItem.WIDTH/2,GameItem.HEIGHT/2))
            self.m_pSprite:setAnchorPoint(0.5,0.5)
	    end

	end

end

function GameItem:runRotate(_time)
    print(_time,"_time")
    local Rotate = cc.Sequence:create(
            cc.DelayTime:create(_time),
            cc.RotateTo:create(0.09, -10),
            cc.RotateTo:create(0.09, 10),
            cc.RotateTo:create(0.09, 0),
            cc.CallFunc:create(function () 
                ExternalFun.playSoundEffect("SingleDrop.wav")
             end)
            )
            
    self.m_pSprite:runAction(Rotate)
end

return GameItem