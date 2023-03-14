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
cmd.KIND_ID						= 531
--游戏人数
cmd.GAME_PLAYER					= 1

--进入时的游戏模式
cmd.GM_NULL						= 1				--正常
cmd.GM_FREE				        = 2				--FREETIME
cmd.GM_BOUNS                    = 3             --小玛莉(小游戏),没用上

--状态定义
cmd.GAME_SCENE_WAIT			= 100		--等待开始
cmd.GAME_SCENE_ONE			= 101		--游戏开始旋转
cmd.GAME_SCENE_FREETIME		= 102		--FREETIME

--游戏状态
cmd.CMD_S_StatusFree =
{
    {k = "cbYaXianCount", t = "byte"},                     --总压线, 50
    {k = "game_mode", t = "byte"},                         --用户状态, 1正常，2免费模式, 3小玛莉
    {k = "bouns_count", t = "byte"},                       --小玛莉,用不上
    {k = "frees_count", t = "byte"},                       --免费游戏次数
    {k = "winScore", t = "score"},                         --输赢金币
    {k = "zJLineArray", t = "byte", l = {50}},             --开奖结果,0没中，有数字表示当条线中了几个
    {k = "result_icons", t = "byte", l = {4, 5}},          --面板图标结果
    {k = "bonus_step", t = "byte"},                        --总压线,用不上
    {k = "lBounsWinScore", t = "score", l = {5}},          --bouns总赢分,用不上
    {k = "lScore", t = "score"},                           --我的金币数
    {k = "freeWinScore", t = "score"},                     --免费期间总共赢的金币
    {k = "nTotalModeCounts", t = "int"},                   --免费模式总次数
    {k = "nMysteryNewType", t = "byte"},                   --面具变成什么图标
    {k = "dwHashID", t = "dword"},
    {k = "dwCRC", t = "dword"},
}

--服务器消息字段
cmd.SUB_S_GAME_START				= 100		--游戏开始返回
cmd.SUB_S_GAME_CONFIG               = 104       --服务配置

--游戏开始
cmd.CMD_S_GameStart =
{
    {k = "bouns_status", t = "byte"},                   --用不上
    {k = "zsGameCount", t = "byte"},                    --免费游戏次数
    {k = "lWinScore", t = "score"},                     --输赢金币
    {k = "lScore", t = "score"},                        --我的金币数
    {k = "zJLineArray", t = "byte", l = {50}},          --中奖线
    {k = "result_icons", t = "byte", l = {4, 5}},       --面板图标结果
    {k = "game_mode", t = "byte"},                      --用户状态, 1正常，2免费模式, 3小玛莉
    {k = "nMysteryNewType", t = "byte"},                --面具变成什么图标
    {k = "dwHashID", t = "dword"},
    {k = "dwCRC", t = "dword"},
}

--场景消息之前
cmd.CMD_S_GameConfig =
{
    {k = "game_version", t = "byte"},               -- kGameVersion的值
    {k = "betArray", t = "int", l = {10}},          -- 一条线的底注列表
    {k = "small", t = "score"},                     -- 最小飘中奖面板数额
    {k = "middle", t = "score"},                    --
    {k = "big", t = "score"},                       --
}

cmd.SUB_C_ONE_START		= 3  --开始游戏

--开始游戏 协议
cmd.CMD_C_OneStart =
{
    {k = "total_AddCount", t = "int"},     --总下注
}

return cmd