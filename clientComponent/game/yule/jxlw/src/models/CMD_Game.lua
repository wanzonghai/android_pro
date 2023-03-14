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
cmd.KIND_ID						= 525
	
--游戏人数
cmd.GAME_PLAYER					= 1

--数目定义
cmd.ITEM_COUNT 					= 9				--图标数量
cmd.ITEM_X_COUNT				= 5				--图标横坐标数量
cmd.ITEM_Y_COUNT				= 3				--图标纵坐标数量
cmd.YAXIANNUM					= 9				--压线数字



--状态定义
cmd.JXLW_GAME_SCENE_FREE			= 0			--等待开始
cmd.JXLW_GAME_SCENE_ONE			= 101		--水浒传开始

--命令定义
cmd.SUB_S_GAME_START				= 100		--压线开始
cmd.SUB_S_UPDATE_ROOM_STORAGE		= 115		--更新彩金池子
cmd.SUB_S_USER_DATA					= 120       --更新用户积分	

--空闲状态
cmd.JXLW_CMD_S_StatusFree = 
{
	--游戏属性
	{k="lCellScore",t="int"},				--基础押分
 	{k="lCaiJin",t="score"},                --彩金池
	{k="lUserScore",t="score"},              --用户积分
	{k="lWinTotal",t="score"},                --累计赢分
    --上一把的游戏记录
	{k="lScore",t="score"},--游戏得分
    {k="nMultiple",t="int",l={9}},   --每条线中奖的倍数
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},--开奖信息
    {k="cbItemType",t="byte",l={9}},  --中奖图标
    {k="cbLineCount",t="byte",l={9}},  --每条线中奖个数
	{k="cbFreeTime",t="byte"},--免费次数
    {k="cbBetLineCount",t="byte"},--押线数
    {k="cbBetMultiple",t="byte"} --倍数
}

--游戏开始
cmd.JXLW_CMD_S_GameStart = 
{
	--下注信息
	{k="lScore",t="score"},--游戏得分
    {k="nMultiple",t="int",l={9}},   --每条线中奖的倍数
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},--开奖信息
    {k="cbItemType",t="byte",l={9}},  --中奖图标
    {k="cbLineCount",t="byte",l={9}},  --每条线中奖个数
	{k="cbFreeTime",t="byte"},--免费次数
	{k="dwHashID",t="dword"},--免费次数
}

cmd.JXLW_CMD_S_UPDATE_CAIJING = 
{
	{k="lCaiJin",t="score"},                --彩金池
}

cmd.JXLW_CMD_S_User_data = 
{
    {k="bScatter",t="bool"},  --是否在免费次数
    {k="wChairID",t="word"},  --椅子号
	{k="lWinScore",t="score"},--赢分
	{k="lUserScore",t="score"},--用户身上金币
	{k="lWinTotal",t="score"},--累计赢分
}

cmd.JXLW_SUB_C_ONE_START = 6    --押线开始


return cmd