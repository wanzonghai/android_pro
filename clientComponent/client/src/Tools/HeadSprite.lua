HeadSprite = {}
HeadSprite.TAG = "HeadSprite"
import(appdf.CLIENT_SRC.."Tools.DownloadPic")

--创建裁剪玩家头像
function HeadSprite.__createClipHead(spr,mask)
    local sprSize = spr:getContentSize();
    local stencil = cc.Sprite:create(mask or "client/res/public/clip.png");
	-- local stencil = cc.Sprite:createWithSpriteFrameName(mask or "client/res/public/clip.png");
    stencil:setContentSize(sprSize)
    local clipper = cc.ClippingNode:create();
    clipper:setContentSize(sprSize)
    clipper:setStencil(stencil);
    clipper:setInverted(false);
    clipper:setAlphaThreshold(0.05);
    clipper:addChild(spr);
    return clipper
end

function HeadSprite.loadHeadImg(headNode,gameID,faceID,isClip,size)
    faceID = faceID or 1
    size = size or headNode:getContentSize()
    --default head path
    local imgPath = "client/res/public/Face"..faceID..".jpg"
    --local head path
    local localPath = DownloadPic:isFileNamePath(gameID)
    if localPath then
        imgPath = localPath
    end

    headNode:removeAllChildren()
    local headImg = cc.Sprite:create(imgPath)
    -- local headImg = cc.Sprite:createWithSpriteFrameName(imgPath)
    headImg:setContentSize(size)
    local children = headImg
    if isClip then
        children = HeadSprite.__createClipHead(headImg)
    end
    children:addTo(headNode):setPosition(cc.p(size.width/2,size.height/2))
    --return Head Image Node
    return headImg
end

function HeadSprite.loadHeadUrl(headImg,gameID,headurl)
    if tolua.isnull(headImg) then
        return
    end

    DownloadPic:downloadNetPic(headurl,gameID,function (result,path)
        if result then
            if tolua.isnull(headImg) then
                return
            end
            local size = headImg:getContentSize()
            if headImg.setTexture then
                headImg:setTexture(path)
                headImg:setContentSize(size)
            elseif headImg.loadTexture then
                headImg:loadTexture(path)
                headImg:setContentSize(size)
            end
        end
    end,false)
end

function HeadSprite.isFileNamePath(gameID)
    return DownloadPic:isFileNamePath(gameID)
end
