--
-- Author: senji
-- Date: 2015-06-10 16:13:25
--
TextField.CCNODE_TYPE_SCALE9IMG = "scale9img"
TextField.CCNODE_TYPE_MJ_LAY = "mjLay"
TextField.CCNODE_TYPE_MJ_LAY_GROUP = "mjLayGoup"
TextField.CCNODE_TYPE_MJ_LAY_GROUP_AN_GANG = "mjLayGroupAnGang"
TextField.CCNODE_TYPE_MJ_LAY_GROUP_MING_GANG = "mjLayGroupMingGang"

-- 这里重写TextField的构造器
function TextField.CCNodeCreater(htmlNodeVo)
    local params = string.split(htmlNodeVo.imgSrc, "|");
    local type = params[1]
    local node = TextField.getCCNodeFromPool(type);
    if node then
        if type == TextField.CCNODE_TYPE_MJ_LAY then
            local dataInt = parseInt(params[2])
            node:setDataInt(dataInt)
            node:setIsGray(params[3] == "true")
            node:setIsHu(params[4] == "true")
        elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP then
            local datas = string.split(params[2], ",");
            node:setData(datas)
        elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP_AN_GANG then
            local datas = string.split(params[2], ",");
            node:setData(datas)
        elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP_MING_GANG then
            local datas = string.split(params[2], ",");
            node:setData(datas)
        elseif type == TextField.CCNODE_TYPE_SCALE9IMG then
            node = ccui.ImageView:create(params[2]);
            node:setScale9Enabled(true)
            node:setContentSize(cc.size(params[3], params[4]));
            node:setCapInsets(cc.rect(params[5] or 2, params[6] or 2, params[7] or 2, params[8] or 2));
            node:ignoreContentAdaptWithSize(false)
            node:retain()
        end
    end
    return node;
end

function TextField:onDefaultTextLinkHooker(htmlEvent, worldPos)
    linkMgr:executeLink(htmlEvent, worldPos)
end

function TextField.getCCNodeFromPool(type)
    local node = nil;
    local isFromCache = false;
    if type == TextField.CCNODE_TYPE_MJ_LAY then
        node, isFromCache = ccsPoolMgr:get("csb/common/MJCardLayPortrait.csb", false)
    elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP then
        node, isFromCache = ccsPoolMgr:get("csb/common/MJGroupPengUp.csb", false)
    elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP_MING_GANG then
        node, isFromCache = ccsPoolMgr:get("csb/common/MJGroupGangUp.csb", false)
    elseif type == TextField.CCNODE_TYPE_MJ_LAY_GROUP_AN_GANG then
        node, isFromCache = ccsPoolMgr:get("csb/common/MJGroupAnGangUp.csb", false)
    elseif type == TextField.CCNODE_TYPE_SCALE9IMG then
        node = true
    end
    if node and type ~= TextField.CCNODE_TYPE_SCALE9IMG then
        node.__ccsTFType = type;
    end
    return node
end

-- 重写textfield的函数，返回是否缓存
function TextField:try2Cache(node)
    -- if node.__ccsTFType == TextField.CCNODE_TYPE_GRID_ITEM then
    -- end
    -- if node.__ccsTFType == TextField.CCNODE_TYPE_GRID_ITEM or node.__ccsTFType == TextField.CCNODE_TYPE_GRID_SURVIVOR then --tf 格子有缩放效果时会改锚点为0.5，缓存时重置下
    --     node:setAnchorPoint(cc.p(0, 0))
    -- end
    local b = ccsPoolMgr:put(node)
    return b;
end
