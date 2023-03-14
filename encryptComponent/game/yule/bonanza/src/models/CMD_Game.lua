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
cmd.KIND_ID						= 704
--游戏人数
cmd.GAME_PLAYER					= 1
--数目定义
cmd.ITEM_COUNT 					= 11			--图标数量
cmd.ITEM_X_COUNT				= 6				--图标横坐标数量
cmd.ITEM_Y_COUNT				= 5				--图标纵坐标数量
cmd.YAXIANNUM					= 11			--压线数字
cmd.BET_INDEX_NUM               = 10            --下注额度列表数

--进入时的游戏模式
cmd.GM_NULL						= 0				--正常
cmd.GM_FREE				        = 1				--FREETIME

--状态定义
cmd.GAME_SCENE_WAIT			= 100		--等待开始
cmd.GAME_SCENE_ONE			= 101		--游戏开始旋转
cmd.GAME_SCENE_FREETIME		= 102		--FREETIME

--游戏状态
cmd.CMD_S_StatusFree =
{
    {k = "dwBetScore", t = "dword", l = {cmd.BET_INDEX_NUM}},   --下注额度列表
    --非免费模式，下面三个值都相等
    {k = "lGameTotalScores", t = "score"},                      --游戏得分，总得分(触发免费和免费总获得，没触发就不加免费获得的金币)
    {k = "lGameModeScores", t = "score"},                       --游戏得分，当前模式得分
    {k = "lGameScores", t = "score"},                           --游戏得分，本轮得分
    {k = "lUserScore", t = "score"},                            --用户金币
    {k = "cbFreeTimes", t = "byte"},                            --免费次数
    {k = "nBoomMultiples", t = "int"},                          --免费模式已滚动次数的炸弹总倍数
    {k = "nTotalModeCounts", t = "int"},                        --免费模式总次数
    {k = "cbItemInfo", t = "int", l = {cmd.ITEM_Y_COUNT, cmd.ITEM_X_COUNT}},       --面板结果
    {k = "lGetScoreStep", t = "score", l = {3}},                --弹大奖的取值范围
    {k = "dwHashID", t = "dword"},                              --校验使用
    {k = "dwCRC", t = "dword"},                                 --对 cbItemInfo CRC 校对
}

cmd.SUB_S_GAME_START				= 100		--游戏开始返回

--[[
    cbItemInfo =
    {
        {a, b, c, d, e, f},
        {g, h, i, j, k, l},
        {m, n, o, p, q, r},
        {s, t, u, v, w, x},
        {y, z, 1, 2, 3, 4}
    }
--面板上的排列 从上到下，从做到右 跟上面的是一样的

]]

cmd.tagGameData =
{
    {k = "cbFrees", t = "byte"},    --此次获得的免费次数,此字段说明有新的免费模式次数。
    {k = "lScore", t = "score"},        --此次中奖积分
    {k = "cbJLineArray", t = "byte", l = {cmd.YAXIANNUM}},      --中奖元素个数，数组为0表示没有中奖
    {k = "cbIconType", t = "byte", l = {cmd.YAXIANNUM}},        --中奖元素类型，数组为0表示没有中奖
    {k = "cbItemInfo", t = "int", l = {cmd.ITEM_Y_COUNT, cmd.ITEM_X_COUNT}},   --面板结果
    {k = "dwCRC", t = "dword"},                         --对 cbItemInfo CRC 校对
}

--游戏开始
cmd.CMD_S_GameStart =
{
    {k = "lScore", t = "score"},            --中奖总共赢的金币
    {k = "lUserScore", t = "score"},        --结算后的用户金币
    {k = "cbFreeTimes", t = "byte"},        --总的免费次数，此字段说明有新的免费模式次数。
    {k = "cbGameMode", t = "byte"},        --游戏模式，0正常，1，免费模式
    {k = "dwHashID", t = "dword"},        --本局ID,校验使用
    {k = "cbDataCount", t = "byte"},        --tagGameData 个数，消除玩法,有几次消除玩法就有几个count
    {k = "tGameData", t = "table", l = {}, d = cmd.tagGameData}
}

cmd.SUB_C_ONE_START		= 6  --开始游戏

--开始游戏 协议
cmd.CMD_C_OneStart =
{
    {k = "cbBetIndex", t = "byte"},     --下注额度的index
}

return cmd