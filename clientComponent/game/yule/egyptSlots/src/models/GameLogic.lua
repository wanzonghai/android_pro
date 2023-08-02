local GameLogic = GameLogic or {}

--数目定义
GameLogic.ITEM_COUNT 				= 9				--图标数量
GameLogic.ITEM_X_COUNT				= 5				--图标横坐标数量
GameLogic.ITEM_Y_COUNT				= 3				--图标纵坐标数量
GameLogic.YAXIANNUM					= 9				--压线数字

--逻辑类型
GameLogic.CT_LIZHI					= 0				--荔枝
GameLogic.CT_JUZI					= 1				--橘子
GameLogic.CT_NIHOUTAO				= 2				--猕猴桃
GameLogic.CT_XIGUA					= 3				--西瓜
GameLogic.CT_PINGGUO				= 4				--苹果
GameLogic.CT_LIZI					= 5				--栗子
GameLogic.CT_PUTAO					= 6				--葡萄
GameLogic.CT_LINDANG				= 7				--铃铛
GameLogic.CT_XIANGJIAO				= 8				--香蕉
GameLogic.CT_BOLUO					= 9				--菠萝
GameLogic.CT_SHUIHUZHUAN			= 10			--BAR
GameLogic.CT_ZHUANSHI				= 11			--钻石
GameLogic.CT_BOX					= 12			--宝箱
GameLogic.CT_777					= 13			--777

--可能中奖的位置线
GameLogic.m_ptXian = {}
--[[GameLogic.m_ptXian[1] = {{x=2,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=2,y=5}} --第二条直线
GameLogic.m_ptXian[2] = {{x=1,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=1,y=5}}	--第一条直线
GameLogic.m_ptXian[3] = {{x=3,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=3,y=5}}	--第三条直线
GameLogic.m_ptXian[4] = {{x=1,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=1,y=5}}	--	大v字
GameLogic.m_ptXian[5] = {{x=3,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=3,y=5}}	--  倒大v字  
GameLogic.m_ptXian[6] = {{x=1,y=1},{x=1,y=2},{x=2,y=3},{x=1,y=4},{x=1,y=5}}	--  
GameLogic.m_ptXian[7] = {{x=3,y=1},{x=3,y=2},{x=2,y=3},{x=3,y=4},{x=3,y=5}}
GameLogic.m_ptXian[8] = {{x=2,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=2,y=5}}
GameLogic.m_ptXian[9] = {{x=2,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=2,y=5}}
]]--
GameLogic.m_ptXian[1] = {{x=2,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=2,y=5}} --第二条直线
GameLogic.m_ptXian[2] = {{x=1,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=1,y=5}}	--第一条直线
GameLogic.m_ptXian[3] = {{x=3,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=3,y=5}}	--第三条直线
GameLogic.m_ptXian[4] = {{x=1,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=1,y=5}}	--大v字
GameLogic.m_ptXian[5] = {{x=3,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=3,y=5}}	--倒大v字  
GameLogic.m_ptXian[6] = {{x=2,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=2,y=5}}	--  
GameLogic.m_ptXian[7] = {{x=2,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=2,y=5}}
GameLogic.m_ptXian[8] = {{x=1,y=1},{x=1,y=2},{x=2,y=3},{x=3,y=4},{x=3,y=5}}
GameLogic.m_ptXian[9] = {{x=3,y=1},{x=3,y=2},{x=2,y=3},{x=1,y=4},{x=1,y=5}}
----------------------------------------------------------

--取得中奖分数
function GameLogic:GetZhongJiangTime( cbIndex ,cbItemInfo )
	local ptXian = GameLogic.m_ptXian[cbIndex]
	local item_x_count = GameLogic.ITEM_X_COUNT

	local xian=1
	local nTime = 0
	local bLeftLink = true
	local bRightLink = true
	local maxBeishu = 0

	local nLeftBaseLindCount = 0
	local nRightBaseLinkCount = 0

	local cbLeftFirstIndex = 1
	local cbRightFirstIndex = item_x_count

	for i=1,item_x_count do
		--左
		if cbItemInfo[ptXian[i].x][ptXian[i].y] ~= GameLogic.CT_SHUIHUZHUAN and  bLeftLink == true then
			cbLeftFirstIndex = i
			bLeftLink = false
		end
	end

	bLeftLink = true

	for i=1,item_x_count do
		--左到右基本奖
		if (cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] == cbItemInfo[ptXian[i].x][ptXian[i].y] or cbItemInfo[ptXian[i].x][ptXian[i].y] == GameLogic.CT_SHUIHUZHUAN) and bLeftLink == true then
			nLeftBaseLindCount = nLeftBaseLindCount + 1
		else
			bLeftLink = false
		end
	end
	if nLeftBaseLindCount == 5 then
		maxBeishu=nLeftBaseLindCount
		local itemType  = cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] 
		xian=itemType
		if itemType == GameLogic.CT_LIZHI then
			nTime = nTime + 2000
		elseif itemType == GameLogic.CT_JUZI then
			nTime = nTime + 300
		elseif itemType == GameLogic.CT_NIHOUTAO then
			nTime = nTime + 250
		elseif itemType == GameLogic.CT_XIGUA then
			nTime = nTime + 200
		elseif itemType == GameLogic.CT_PINGGUO then
			nTime = nTime + 150
		elseif itemType == GameLogic.CT_LIZI then
			nTime = nTime + 100
		elseif itemType == GameLogic.CT_PUTAO then
			nTime = nTime + 90
		elseif itemType == GameLogic.CT_LINDANG then
			nTime = nTime + 85
		elseif itemType == GameLogic.CT_XIANGJIAO then
			nTime = nTime + 80
		elseif itemType == GameLogic.CT_BOLUO then
			nTime = nTime + 75
		elseif itemType == GameLogic.CT_SHUIHUZHUAN then
			nTime = nTime + 5000
		elseif itemType == GameLogic.CT_ZHUANSHI then
			nTime = nTime + 8000
		elseif itemType == GameLogic.CT_BOX then
			nTime = nTime + 10000
		elseif itemType == GameLogic.CT_777 then
			nTime = nTime + 5000
		end
	elseif nLeftBaseLindCount == 3 or nLeftBaseLindCount == 4 then
		maxBeishu=nLeftBaseLindCount
		local itemType  = cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] 
		xian=itemType
		if itemType == GameLogic.CT_LIZHI then
			nTime = nTime + (nLeftBaseLindCount == 3 and 50 or 200)
		elseif  itemType == GameLogic.CT_JUZI then
			nTime = nTime + (nLeftBaseLindCount == 3 and 20 or 50)
		elseif  itemType == GameLogic.CT_NIHOUTAO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 15 or 25)
		elseif  itemType == GameLogic.CT_XIGUA then
			nTime = nTime + (nLeftBaseLindCount == 3 and 10 or 20)
		elseif  itemType == GameLogic.CT_PINGGUO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 8 or 20)
		elseif  itemType == GameLogic.CT_LIZI then
			nTime = nTime + (nLeftBaseLindCount == 3 and 6 or 20)
		elseif  itemType == GameLogic.CT_PUTAO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 5 or 40)
		elseif  itemType == GameLogic.CT_LINDANG then
			nTime = nTime + (nLeftBaseLindCount == 3 and 8 or 35)
			elseif  itemType == GameLogic.CT_XIANGJIAO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 6 or 30)
			elseif  itemType == GameLogic.CT_BOLUO then
			nTime = nTime + (nLeftBaseLindCount == 3 and 5 or 15)
		
		elseif  itemType == GameLogic.CT_SHUIHUZHUAN then
			nTime = nTime + (nLeftBaseLindCount == 3 and 100 or 900)
				elseif  itemType == GameLogic.CT_ZHUANSHI then
			nTime = nTime + (nLeftBaseLindCount == 3 and 100 or 2000)
				elseif  itemType == GameLogic.CT_BOX then
			nTime = nTime + (nLeftBaseLindCount == 3 and 500 or 5000)
				elseif  itemType == GameLogic.CT_777 then
			nTime = nTime + (nLeftBaseLindCount == 3 and 1000 or 3000)
		end
    end
	return nTime,xian,maxBeishu
end
--全部中奖信息
function GameLogic:GetAllZhongJiangInfo( cbItemInfo ,ptZhongJiang)

	local cbZhongJiangCount = 0
	for i=1,GameLogic.ITEM_COUNT do
		cbZhongJiangCount = cbZhongJiangCount + self:GetZhongJiangXian(cbItemInfo,GameLogic.m_ptXian[i],ptZhongJiang[i])
	end

	return cbZhongJiangCount
end
--单条中奖信息
function GameLogic:getZhongJiangInfo( cbIndex ,cbItemInfo)--,cbZhongJiang)
	local cbZhongJiang = {}
	return self:GetZhongJiangXian(cbItemInfo,GameLogic.m_ptXian[cbIndex],cbZhongJiang)
end

--全盘中奖
function GameLogic:GetQuanPanJiangTime( cbItemInfo )
	local nTime = 0
	local bSingle = true
	local ptFirstIndex = {x=0xFF,y=0xFF}

	for i=1,GameLogic.ITEM_Y_COUNT do
		for j=1,GameLogic.ITEM_X_COUNT do
			if ptFirstIndex.x == 0xFF then
				ptFirstIndex.x = i
				ptFirstIndex.y = j
			elseif cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] ~= cbItemInfo[i][j] then
				--print("cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]，cbItemInfo[i][j]/3",math.floor(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3),math.floor(cbItemInfo[i][j]/3))
				print(ptFirstIndex.x.."  "..ptFirstIndex.y.."i="..i.."j="..j);
				print(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]);
				print(cbItemInfo[i][j]/3)
				print(GameLogic.CT_ZHUANSHI )
				if math.floor(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3) ~= math.floor(cbItemInfo[i][j]/3) or 
					cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] >= GameLogic.CT_ZHUANSHI 
					or cbItemInfo[i][j] >= GameLogic.CT_ZHUANSHI then
					return 0
				end
				bSingle = false
			end
		end

	end
	--print("全盘中奖 bSingle",bSingle)
	if not bSingle then
		dump(cbItemInfo)
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
		if tempType == GameLogic.CT_LIZHI then
			nTime = 50
		elseif tempType == GameLogic.CT_JUZI then
			nTime = 100
		elseif tempType == GameLogic.CT_NIHOUTAO then
			nTime = 150
		elseif tempType == GameLogic.CT_XIGUA then
			nTime = 200
		elseif tempType == GameLogic.CT_PINGGUO then
			nTime = 250
		elseif tempType == GameLogic.CT_LIZI then
			nTime = 300
		elseif tempType == GameLogic.CT_PUTAO then
			nTime = 400
		elseif tempType == GameLogic.CT_LINDANG then
			nTime = 500
        elseif tempType == GameLogic.CT_XIANGJIAO then
			nTime = 600
		elseif tempType == GameLogic.CT_BOLUO then
			nTime = 1000
		elseif tempType == GameLogic.CT_SHUIHUZHUAN then
			nTime = 2000
         elseif tempType == GameLogic.CT_ZHUANSHI then
			nTime = 3000
		elseif tempType == GameLogic.CT_BOX then
			nTime = 4000
		elseif tempType == GameLogic.CT_777 then
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
		if cbItemInfo[ptXian[i].x][ptXian[i].y] ~= GameLogic.CT_SHUIHUZHUAN and  bLeftLink == true then
			cbLeftFirstIndex = i
			bLeftLink = false
		end
	end

	bLeftLink = true
	bRightLink = true

	--中奖线
	for i=1,item_x_count do
		--从左到右基本奖
		if (cbItemInfo[ptXian[cbLeftFirstIndex].x][ptXian[cbLeftFirstIndex].y] == cbItemInfo[ptXian[i].x][ptXian[i].y]  or  cbItemInfo[ptXian[i].x][ptXian[i].y] == GameLogic.CT_SHUIHUZHUAN ) and bLeftLink == true  then
			nLeftBaseLinkCount = nLeftBaseLinkCount+1
		else
			bLeftLink = false
		end
	end

	local nLinkCount = 0
	if nLeftBaseLinkCount >=3 then
		for i=1,nLeftBaseLinkCount do
			ptZhongJiang[i].x = ptXian[i].x
			ptZhongJiang[i].y = ptXian[i].y
		end
		nLinkCount = nLinkCount + nLeftBaseLinkCount
	end
	return math.min(5,nLinkCount)
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