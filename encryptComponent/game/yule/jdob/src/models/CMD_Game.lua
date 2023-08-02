local cmd = {}

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
cmd.VERSION 					= appdf.VersionValue(7,0,1)
--游戏标识
cmd.KIND_ID						= 602

--单注最多投注几个数字
cmd.ITEM_OPEN_COUNT                     = 5

--游戏状态
cmd.gameState = {
    bet = 100,  --投注状态 
    endAnim = 101, --结算状态
}

--大类别
cmd.betItemType = {
    eNumber = 0,  --数字 
    eAnim = 1, --动物
}
--小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
--小类别最低投注数
cmd.betStartNum = {
    eNumber = 2,   
    eAnim = 1,
}

--房间名长度
cmd.LEN_NICKNAME                = 32

--区域索引 (lua的table默认下标为1，所以使用的过程中应当加1)
cmd.AREA_MAX					= 3									--最大区域

--游戏进行
cmd.GAME_PLAY					= 100

--游戏倒计时
cmd.kGAMEFREE_COUNTDOWN			= 1
cmd.kGAMEPLAY_COUNTDOWN			= 2
cmd.kGAMEOVER_COUNTDOWN			= 3

---------------------------------------------------------------------------------------
--服务器命令结构
cmd.SUB_S_GAME_START      = 100                 --游戏开始切到下注
cmd.SUB_S_PLACE_JETTON      = 101                 --用户下注
cmd.SUB_S_GAME_END          = 102                 --游戏结束(开奖)
cmd.SUB_S_CHANGE_USER_SCORE   = 105                 --更新积分
--cmd.SUB_S_SEND_OPENRECORD     = 106                 --游戏记录
cmd.SUB_S_USER_DATA               = 107             --用户赢分反馈（主要处理其他人，暂时未用到） 
cmd.SUB_S_PLACE_JETTON_FAIL   = 108                 --下注失败
cmd.SUB_S_SEND_ADDBETRECORD     = 115             --用户下注记录
cmd.SUB_S_UPDATE_OCCUPYSEAT     = 118  --更新占位
cmd.SUB_S_USER_BET_DATA         = 119         --更新用户下注信息(下注记录)
---------------------------------------------------------------------------------------
--下注失败结构
cmd.CMD_S_PlaceBetFail = {
    { k="wPlaceUser", t="word"},        --下注玩家
    { k="lBetArea", t="byte"},       --下注区域
    { k="lPlaceScore", t="score"},        --当前下注
}
--用户下注
cmd.CMD_S_PlaceBet = {
    { k="wChairID", t="word"},       --用户位置
    { k="cbBetItemType", t="byte"}, --大类别  0 数组 1 动物 
    { k="cbBetType", t="byte"}, --小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
    { k ="cbBetNum", t="byte", l={5}},--下注号码 最多5个
    { k="llBetscore", t="score"},       --下注货币数量
}
--下注记录结构
cmd.BETINFO =
{
    {k = "cbBetItemType", t = "byte"},  --大类别  0 数组 1 动物 
    {k = "cbBetType", t = "byte"},  --小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
    {k = "llBetscore", t = "score"},--下注货币数量
    {k = "llWinscore", t = "score"},--赢得货币数量
    {k = "dwBetIndex", t = "dword"},--下注序号
    {k = "cbBetNum", t = "byte", l={5}},--下注号码 最多5个
}
--下注记录
cmd.CMD_S_SCENE_Bet_info = 
{
    {k = "isOpen", t = "byte"}, --是否开奖
    {k = "cbBetCount", t = "byte"}, --记录条数
    {k = "cbBetArray", t = "table", d = cmd.BETINFO},--记录数组
}
--开奖结果
cmd.CMD_S_GameEnd = {
    { k="cbEndTimer", t="int"},       --总时间  结束
    { k="betArray", t="byte", l={5}}, --开奖结果动物
    { k="betNum", t="byte", l={5, 4}},   --开奖结果结果动物对应数字
    { k="win_score", t="score"},   --赢分
    { k="user_score", t="score"},   --用户身上金币
    { k="otherWins", t="score", l={4}}, --占位椅子用户赢分(其他人)
}
--场景数据
cmd.CMD_S_SCENE_Data = { 
    { k="cbTimeLeave", t="byte"},                  --当前状态剩余时间
    { k="dwBetScore", t="dword", l={5}},                  --下注筹码选择，区间值
    { k="cbGameStatus", t="byte"},                  --游戏状态
    { k="cbAllTime", t="byte"},                  --当前状态总时间
    { k="lAllBet", t="score"},                  --所有玩家总下注
    { k="lPlayBet", t="score"},                  --玩家下注
    { k="lPlayAllScore", t="score"},                  --玩家成绩
    { k="lRevenue", t="score"},                  --税收
    { k="betArray", t="byte", l={5}}, --开奖结果动物
    { k="betNum", t="byte", l={5, 4}},   --开奖结果结果动物对应数字
    { k="showChairIDs", t="word", l={4}}, --占位椅子ID(其他人)
}
--更新占位
cmd.CMD_S_UpdateOccupySeat =
{
    --无效占位id为65535
    {k = "showChairIDs", t = "word", l = {4}} --占位椅子ID
}
--游戏开始切到下注
cmd.CMD_S_GameStart = {
    { k="cbTimeLeave", t="byte"},       --剩余时间
}
--用户赢分反馈（主要处理其他人，暂时未用到）
cmd.CMD_S_User_data ={
    {k="bScatter", t="bool"},  -- 是否在免费次数
    {k="bBouns", t="bool"},    -- 是否在bouns
    {k="wChairID", t="word"},
    {k="lWinScore", t="score"}, -- 赢分
    {k="userScore", t="score"}, -- 用户身上金币
}

---------------------------------------------------------------------------------------
--客户端命令结构
cmd.SUB_C_BET                  =8               --投注（复投也需按单注）
--cmd.SUB_C_DELETEBET                  =20               --删除单注

--下注结构
cmd.BetArray =
{
    {k = "cbBetItemType", t = "byte"},  --大类别  0 数组 1 动物 
    {k = "cbBetType", t = "byte"},  --小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
    {k = "llBetscore", t = "score"},--下注货币数量
    {k = "cbBetNum", t = "byte", l={5}},--下注号码 最多5个
}
--玩家下注
cmd.CMD_C_Bet = 
{
    --投注条数
    {k = "cbBetCount", t = "byte"}, --下注条数(目前固定一注，复投多次发送)
    {k = "cbBetArray", t = "table", d = cmd.BetArray},--下注数组
}

---------------------------------------------------------------------------------------


cmd.RES_PATH 					= 	"jdob/res/"
print("********************************************************load cmd");
return cmd