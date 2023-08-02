local GameLogic = GameLogic or {}

--数目定义
GameLogic.ITEM_COUNT 				= 9				--图标数量
GameLogic.ITEM_X_COUNT				= 5				--图标横坐标数量
GameLogic.ITEM_Y_COUNT				= 3				--图标纵坐标数量
GameLogic.YAXIANNUM					= 20			--压线数字

--逻辑类型

GameLogic.CT_ONE					= 0				--邮件袋
GameLogic.CT_TWO				    = 1				--酒壶
GameLogic.CT_THREE				    = 2				--肚兜
GameLogic.CT_FOUR					= 3				--扇子
GameLogic.CT_FIVE				    = 4				--金叉
GameLogic.CT_SIX					= 5				--金锁
GameLogic.CT_SEVEN			        = 6				--李瓶儿
GameLogic.CT_SCATTER			    = 7			    --免费
GameLogic.CT_WILD			        = 8			    --替代

--可能中奖的位置线
GameLogic.m_ptXian = {}
GameLogic.m_ptXian[1] = {{x=2,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=2,y=5}} --第二条直线
GameLogic.m_ptXian[2] = {{x=1,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=1,y=5}}	--第一条直线
GameLogic.m_ptXian[3] = {{x=3,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=3,y=5}}	--第三条直线
GameLogic.m_ptXian[4] = {{x=1,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=1,y=5}}	--大v字
GameLogic.m_ptXian[5] = {{x=3,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=3,y=5}}	--倒大v字  
GameLogic.m_ptXian[6] = {{x=1,y=1},{x=1,y=2},{x=2,y=3},{x=1,y=4},{x=1,y=5}}	--  
GameLogic.m_ptXian[7] = {{x=3,y=1},{x=3,y=2},{x=2,y=3},{x=3,y=4},{x=3,y=5}}
GameLogic.m_ptXian[8] = {{x=2,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=2,y=5}}
GameLogic.m_ptXian[9] = {{x=2,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=2,y=5}}
GameLogic.m_ptXian[10] = {{x=2,y=1},{x=1,y=2},{x=2,y=3},{x=1,y=4},{x=2,y=5}}
GameLogic.m_ptXian[11] = {{x=2,y=1},{x=3,y=2},{x=2,y=3},{x=3,y=4},{x=2,y=5}}
GameLogic.m_ptXian[12] = {{x=1,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=1,y=5}}
GameLogic.m_ptXian[13] = {{x=3,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=3,y=5}}
GameLogic.m_ptXian[14] = {{x=2,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=2,y=5}}
GameLogic.m_ptXian[15] = {{x=2,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=2,y=5}}
GameLogic.m_ptXian[16] = {{x=1,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=1,y=5}}
GameLogic.m_ptXian[17] = {{x=3,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=3,y=5}}
GameLogic.m_ptXian[18] = {{x=1,y=1},{x=2,y=2},{x=3,y=3},{x=3,y=4},{x=3,y=5}}
GameLogic.m_ptXian[19] = {{x=3,y=1},{x=2,y=2},{x=1,y=3},{x=1,y=4},{x=1,y=5}}
GameLogic.m_ptXian[20] = {{x=1,y=1},{x=3,y=2},{x=1,y=3},{x=3,y=4},{x=1,y=5}}
----------------------------------------------------------
--取得中奖倍数
function GameLogic:GetZhongJiangTime( cbIndex ,cbItemInfo )
	local ptXian = GameLogic.m_ptXian[cbIndex]
	local item_x_count = GameLogic.ITEM_X_COUNT

	local nTime = 0
	local bLeftLink = true
	local bRightLink = true

	local nLeftBaseLindCount = 0
	local nRightBaseLinkCount = 0

	local cbLeftFirstIndex = 1
	local cbRightFirstIndex = item_x_count

	for i=1,item_x_count do
		--左
		if cbItemInfo[ptXian[i].x][ptXian[i].y] ~= GameLogic.CT_WILD and  bLeftLink == true then
			cbLeftFirstIndex = i
			bLeftLink = false
		end
		--右
--		if cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y] ~= GameLogic.CT_SHUIHUZHUAN and  bRightLink == true then
--			cbRightFirstIndex = item_x_count-i+1
--			bRightLink = false
--		end
	end

	bLeftLink = true
	bRightLink = true

	for i=1,item_x_count do
		--左到右基本奖
		if (cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] == cbItemInfo[ptXian[i].x][ptXian[i].y] or (cbItemInfo[ptXian[i].x][ptXian[i].y] == GameLogic.CT_WILD and cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] ~= GameLogic.CT_SCATTER )) and bLeftLink == true then
			nLeftBaseLindCount = nLeftBaseLindCount + 1
		else
			bLeftLink = false
		end
--		--右到左基本奖
--		if (cbItemInfo[ptXian[cbRightFirstIndex].x][ptXian[cbRightFirstIndex].y] == cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y] or cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y] == GameLogic.CT_SHUIHUZHUAN) and bRightLink == true then
--			nRightBaseLinkCount = nRightBaseLinkCount + 1
--		else
--			bRightLink = false
--		end
	end


	if nLeftBaseLindCount == 5 then
		local itemType  = cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] 
		if itemType == GameLogic.CT_ONE then
			nTime = nTime + 45
		elseif itemType == GameLogic.CT_TWO then
			nTime = nTime + 60
		elseif itemType == GameLogic.CT_THREE then
			nTime = nTime + 80
		elseif itemType == GameLogic.CT_FOUR then
			nTime = nTime + 100
		elseif itemType == GameLogic.CT_FIVE then
			nTime = nTime + 150
		elseif itemType == GameLogic.CT_SIX then
			nTime = nTime + 300
		elseif itemType == GameLogic.CT_SEVEN then
			nTime = nTime + 500
        elseif itemType == GameLogic.CT_WILD then
			nTime = nTime + 0        
        elseif itemType == GameLogic.CT_SCATTER then
			nTime = nTime + 0       
		end
    end 
	if nLeftBaseLindCount == 3 or nLeftBaseLindCount == 4 then
		local itemType  = cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] 
		if itemType == GameLogic.CT_ONE then
			nTime = nTime + (nLeftBaseLindCount == 3 and 3 or 10)
		elseif  itemType == GameLogic.CT_TWO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 4 or 15)
		elseif  itemType == GameLogic.CT_THREE then
			nTime = nTime + (nLeftBaseLindCount == 3 and 5 or 20)
		elseif  itemType == GameLogic.CT_FOUR then
			nTime = nTime + (nLeftBaseLindCount == 3 and 8 or 25)
        elseif  itemType == GameLogic.CT_FIVE then
			nTime = nTime + (nLeftBaseLindCount == 3 and 10 or 35)
		elseif  itemType == GameLogic.CT_SIX then
			nTime = nTime + (nLeftBaseLindCount == 3 and 20 or 65)
		elseif  itemType == GameLogic.CT_SEVEN then
			nTime = nTime + (nLeftBaseLindCount == 3 and 30 or 100)
        elseif  itemType == GameLogic.CT_WILD then
			nTime = nTime + 0    
        elseif itemType == GameLogic.CT_SCATTER then
			nTime = nTime + 0        
		end
    end 
--	if nRightBaseLinkCount == 3 or nRightBaseLinkCount == 4 then
--		local itemType  = cbItemInfo[ptXian[cbRightFirstIndex].x][ptXian[cbRightFirstIndex].y] 
--		if itemType == GameLogic.CT_FUTOU then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 2 or 5)
--		elseif  itemType == GameLogic.CT_YINGQIANG then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 3 or 10)
--		elseif  itemType == GameLogic.CT_DADAO then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 5 or 15)
--		elseif  itemType == GameLogic.CT_LU then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 7 or 20)
--		elseif  itemType == GameLogic.CT_LIN then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 10 or 30)
--		elseif  itemType == GameLogic.CT_SONG then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 15 or 40)
--		elseif  itemType == GameLogic.CT_TITIANXINGDAO then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 20 or 80)
--		elseif  itemType == GameLogic.CT_ZHONGYITANG then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 50 or 200)
--		elseif  itemType == GameLogic.CT_SHUIHUZHUAN then
--			nTime = nTime + (nRightBaseLinkCount == 3 and 0 or 0)
--		end
--	end
	return nTime,cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y]
end
--全部中奖信息
function GameLogic:GetAllZhongJiangInfo( cbItemInfo ,ptZhongJiang)

	local cbZhongJiangCount = 0
	for i=1,GameLogic.YAXIANNUM do
		cbZhongJiangCount = cbZhongJiangCount + self:GetZhongJiangXian(cbItemInfo,GameLogic.m_ptXian[i],ptZhongJiang[i])
	end

	return cbZhongJiangCount
end
--单条中奖信息
function GameLogic:getZhongJiangInfo( cbIndex ,cbItemInfo)
	local cbZhongJiang = {}
	return self:GetZhongJiangXian(cbItemInfo,GameLogic.m_ptXian[cbIndex],cbZhongJiang)
end

--全盘中奖
function GameLogic:GetQuanPanJiangTime( cbItemInfo )
	local nTime = 0
	local bSingle = true
	local ptFirstIndex = {x=0xFF,y=0xFF}


    if true then
        return nTime
    end

	for i=1,GameLogic.ITEM_Y_COUNT do
		for j=1,GameLogic.ITEM_X_COUNT do
			if ptFirstIndex.x == 0xFF then
				ptFirstIndex.x = i
				ptFirstIndex.y = j
			elseif cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] ~= cbItemInfo[i][j] then				
				if math.floor(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3) ~= math.floor(cbItemInfo[i][j]/3) or cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] >= GameLogic.CT_TITIANXINGDAO or cbItemInfo[i][j] >= GameLogic.CT_TITIANXINGDAO then
					return 0
				end
				bSingle = false
			end
		end
	end
	if not bSingle then
		local tempType = math.floor(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3)
		if  tempType == 0  then
			nTime = 15
		elseif tempType == 1 then
			nTime = 50
		else
			return 0
		end
	else
		local tempType = cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]
		if tempType == GameLogic.CT_FUTOU then
			nTime = 50
		elseif tempType == GameLogic.CT_YINGQIANG then
			nTime = 100
		elseif tempType == GameLogic.CT_DADAO then
			nTime = 150
		elseif tempType == GameLogic.CT_LU then
			nTime = 250
		elseif tempType == GameLogic.CT_LIN then
			nTime = 400
		elseif tempType == GameLogic.CT_SONG then
			nTime = 500
		elseif tempType == GameLogic.CT_TITIANXINGDAO then
			nTime = 1000
		elseif tempType == GameLogic.CT_ZHONGYITANG then
			nTime = 2500
		elseif tempType == GameLogic.CT_SHUIHUZHUAN then
			nTime = 5000
		else
			return 0
		end
	end
	return nTime
end
--单线中奖
function GameLogic:GetZhongJiangXian( cbItemInfo,ptXian,ptZhongJiang )
	local item_x_count = GameLogic.ITEM_X_COUNT
	local nTime = 0
	local bLeftLink = true
	local bRightLink = true
	local nLeftBaseLinkCount = 0
	local nRightBaseLinkCount = 0

	local cbLeftFirstIndex = 1
	local cbRightFirstIndex = item_x_count 

	for i=1,GameLogic.ITEM_X_COUNT do
		ptZhongJiang[i] = {}
		ptZhongJiang[i].x = 0xFF
		ptZhongJiang[i].y = 0xFF
		--左
		if cbItemInfo[ptXian[i].x][ptXian[i].y] ~= GameLogic.CT_WILD and bLeftLink == true then
			cbLeftFirstIndex = i
			bLeftLink = false
		end
--		--右
--		if cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y] ~= GameLogic.CT_SHUIHUZHUAN and  bRightLink == true then

--			cbRightFirstIndex = item_x_count-i+1
--			bRightLink = false
--		end
	end

--    if cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] == GameLogic.CT_SCATTER  then
--        return 0;
--    end

	bLeftLink = true
	bRightLink = true

	--中奖线
	for i=1,item_x_count do
		--从左到右基本奖
		if (cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] == cbItemInfo[ptXian[i].x][ptXian[i].y]  or  (cbItemInfo[ptXian[i].x][ptXian[i].y] == GameLogic.CT_WILD and cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] ~= GameLogic.CT_SCATTER )) and bLeftLink == true  then
			nLeftBaseLinkCount = nLeftBaseLinkCount+1
		else
			bLeftLink = false
		end
		--从右到左基本奖
--		if (cbItemInfo[ptXian[cbRightFirstIndex].x][ptXian[cbRightFirstIndex].y] == cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y]  or cbItemInfo[ptXian[item_x_count-i+1].x][ptXian[item_x_count-i+1].y] == GameLogic.CT_SHUIHUZHUAN )  and bRightLink == true  then
--			nRightBaseLinkCount = nRightBaseLinkCount+1
--		else
--			bRightLink = false
--		end
	end

	local nLinkCount = 0
	
    if nLeftBaseLinkCount >=3 then
		for i=1,nLeftBaseLinkCount do
			ptZhongJiang[i].x = ptXian[i].x
			ptZhongJiang[i].y = ptXian[i].y
		end
		nLinkCount = nLinkCount + nLeftBaseLinkCount
    end 
    
--	if nRightBaseLinkCount >=3  then
--		for i=1,nRightBaseLinkCount do
--			ptZhongJiang[item_x_count-i+1].x = ptXian[item_x_count-i+1].x
--			ptZhongJiang[item_x_count-i+1].y = ptXian[item_x_count-i+1].y
--		end
--		nLinkCount = nLinkCount + nRightBaseLinkCount
--	end
	return math.min(5,nLinkCount)
end

function GameLogic:GetScatterCount( cbItemInfo )
    local ptZhongJiang = {}
    local count = 0;
    ptZhongJiang.bZhongJiang = {}
    for i = 1, 3 do
         ptZhongJiang.bZhongJiang[i] = { }
        for j = 1, 5 do
            if cbItemInfo[i][j] == GameLogic.CT_SCATTER then
                ptZhongJiang.bZhongJiang[i][j] = true
                count = count+1
            else 
                ptZhongJiang.bZhongJiang[i][j] = false
            end
        end
    end
    if count>=3 then
        ptZhongJiang.bFree = true
    else 
        ptZhongJiang.bFree = false
    end
    return ptZhongJiang
end

-----------------------------------------------------------------------------------

--拷贝表
function GameLogic:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end


return GameLogic