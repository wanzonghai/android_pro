--
-- Author: senji
-- Date: 2014-04-03 12:38:12
--

module("DepthUtil", package.seeall)


-- 层深检测，兼容ccs
-- pParent，要进行层深处理的对象
-- vDisplayObjs 一个children的数组，如果传nil，则自动创建一个所有children的数组出来
-- offsetZorder 从这个zorder起
-- modeXy1X2Y3 层深计算模式：1:xy,2:x,3:y
function checkDisplayObjectDepth(pParent, vDisplayObjs, offsetZorder, modeXy1X2Y3)
    if modeXy1X2Y3 == nil then
        modeXy1X2Y3 = 1;
    end

    if modeXy1X2Y3 == 1 and pParent.checkDepth then
        pParent:checkDepth(offsetZorder or 0);--cpp做层深计算，效率高10倍左右，地图上一旦建筑等数据多时用lua算层深计算会比较坑爹
    else
        vDisplayObjs = vDisplayObjs or pParent:getChildren();
        local temp = {}
        for i,v in ipairs(vDisplayObjs) do
            local str = tostring(v)
            temp[str] = true
        end
        offsetZorder = offsetZorder or 0;


        if modeXy1X2Y3 == 1 then
            --这些sort函数要写成局部函数，否则很容易出现问题，例如pNode1 == pNode2的情况
            local function depthDisObjCompareByXY(pNode1, pNode2)
                if pNode1 and pNode2 then
                    local pos1 = pNode1._posCached or DisplayUtil.ccpCopy(pNode1:getPosition())
                    local pos2 = pNode2._posCached or DisplayUtil.ccpCopy(pNode2:getPosition())
                    if not numberEqual(pos1.y, pos2.y) then
                        return pos1.y > pos2.y;
                    elseif not numberEqual(pos1.x, pos2.x) then
                        return pos1.x > pos2.x;
                    else
                        local specialZorder1 = pNode1.__specialZorder or 0;
                        local specialZorder2 = pNode2.__specialZorder or 0;
                        -- if pNode1 ==  pNode2 then
                        --     print("table.sort又出bug了？")
                        -- end
                        return specialZorder1 > specialZorder2;
                    end
                end
                return pNode1 == nil;
            end    
            table.sort(vDisplayObjs, depthDisObjCompareByXY);
        elseif modeXy1X2Y3 == 2 then
            --这些sort函数要写成局部函数，否则很容易出现问题，例如pNode1 == pNode2的情况
            local function depthDisObjCompareByX(pNode1, pNode2)
                return pNode1:getPositionX() > pNode2:getPositionX();
            end
            table.sort(vDisplayObjs, depthDisObjCompareByX);
        elseif modeXy1X2Y3 == 3 then
            --这些sort函数要写成局部函数，否则很容易出现问题，例如pNode1 == pNode2的情况
            local function depthDisObjCompareByY(pNode1, pNode2)
                return pNode1:getPositionY() > pNode2:getPositionY();
            end
            table.sort(vDisplayObjs, depthDisObjCompareByY);
        end
        for i, pChild in ipairs(vDisplayObjs) do
            if pChild:getParent() == pParent then
                local specOffsetZroder = pChild.__specialOffsetZorder or 0
                pParent:reorderChild(pChild, i + offsetZorder + specOffsetZroder);
            end
        end
    end
end