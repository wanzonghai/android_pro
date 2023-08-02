local cmd = cmd or {}

--[[
******
* 结构体描述
* {k = "key", t = "type", s = len, l = {}}
* k 表示字段名,对应C++结构体变量名
* t 表示字段类型,对应C++结构体变量类型
* s 针对string变量特有,描述长度
* l 针对数组特有,描述数组长度,以table形式,一维数组表示为{N},N表示数组长度,多维数组表示为{N,N},N表示数组长度
* d 针对table类型,即该字段为一个table类型
* ptr 针对数组,此时s必须为实际长度

** egg
* 取数据的时候,针对一维数组,假如有字段描述为 {k = "a", t = "byte", l = {3}}
* 则表示为 变量a为一个byte型数组,长度为3
* 取第一个值的方式为 a[1][1],第二个值a[1][2],依此类推

* 取数据的时候,针对二维数组,假如有字段描述为 {k = "a", t = "byte", l = {3,3}}
* 则表示为 变量a为一个byte型二维数组,长度都为3
* 则取第一个数组的第一个数据的方式为 a[1][1], 取第二个数组的第一个数据的方式为 a[2][1]
******
]]

--游戏版本
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 527
	
--游戏人数
cmd.GAME_PLAYER					= 1

--数目定义
cmd.ITEM_COUNT 					= 9			--图标数量
cmd.ITEM_X_COUNT				= 5				--图标横坐标数量
cmd.ITEM_Y_COUNT				= 3				--图标纵坐标数量
cmd.YAXIANNUM					= 20				--压线数字

cmd.GAMERECORDMAX               = 10            --game记录最大数量



--进入模式
cmd.GM_NULL						= 0				--正常
cmd.GM_FREE				        = 1				--FREETIME
cmd.GM_777						= 2				--777
cmd.GM_BOX						= 3				--BOX



--状态定义
cmd.SHZ_GAME_SCENE_FREE			= 100			--等待开始
cmd.SHZ_GAME_SCENE_PLAY         = 100       --游戏开始
cmd.SHZ_GAME_SCENE_ONE			= 101		--水浒传开始
cmd.SHZ_GAME_SCENE_FREETIME		= 102		--FREETIME
cmd.SHZ_GAME_SCENE_777		    = 103		--777
cmd.SHZ_GAME_SCENE_BOX		    = 104		--BOX

cmd.Event_LoadingFinish  = "Event_LoadingFinish"

--空闲状态
cmd.CMD_S_StatusFree = 
{
--	--游戏属性
    {k="dwFreeTimes",t="dword"},			--下注大小
  	{k="lBaseScore",t="int"},				--基础积分 
--	--下注值	
  	{k="cbBetCount",t="byte"},				--下注数量
	{k="dwBetScore",t="dword",l={5}},		--下注大小

}

--游戏状态
cmd.CMD_S_StatusPlay = 
{
--	--游戏属性
    {k="dwFreeTimes",t="dword"},			--下注大小
  	{k="lBaseScore",t="int"},				--基础积分 
--	--下注值	
  	{k="cbBetCount",t="byte"},				--下注数量
	{k="dwBetScore",t="dword",l={5}},		--下注大小
}

--命令定义
cmd.SUB_S_GAME_START				= 100		--压线开始

cmd.tagChildItem = 
{
    {k="lScore",t="score"},--中奖积分--
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},   --开奖信息
}
--游戏开始
cmd.CMD_S_GameStart = 
{
-- 下注信息
	{k="lScore",t="score"},--中奖积分--
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},   --开奖信息
	{k="cbFreeTimes",t="byte"},--此次获得的免费次数
    {k="cbGameMode",t="byte"},
    {k="cbCountinueCounts",t="byte"},
    {k="childitem",t="table",l={50},d=cmd.tagChildItem}
}



cmd.SUB_C_ONE_START		= 6  --水浒传开始


--用户叫分
cmd.CMD_C_OneStart =
{
	{k="lSingleLineBet",t="score"},
}


return cmd