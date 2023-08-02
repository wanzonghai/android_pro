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
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 903
	
--游戏人数
cmd.GAME_PLAYER					= 200

--房间名长度
cmd.SERVER_LEN					= 32
cmd.LEN_NICKNAME                = 32
cmd.SERVER_SEEDLEN              = 65
cmd.MAX_SCORE_HISTORY           = 65
cmd.MAX_PAGE_COUNT              = 10

--游戏记录长度
cmd.RECORD_LEN					= 5

--视图位置
cmd.MY_VIEWID					= 2

--区域索引 (lua的table默认下标为1，所以使用的过程中应当加1)
cmd.AREA_XIAN					= 0									--闲家索引
cmd.AREA_PING					= 1									--平家索引
cmd.AREA_ZHUANG					= 2									--庄家索引
cmd.AREA_TYPE                   = 4                                 --类型
cmd.AREA_MAX					= 16									--最大区域

--区域倍数multiple
cmd.MULTIPLE_XIAN				= 2									--红色倍数
cmd.MULTIPLE_PING				= 14							    --白色倍数
cmd.MULTIPLE_ZHUANG				= 2									--黑色倍数

--占座索引
cmd.SEAT_LEFT1_INDEX            = 0                                 --左一
cmd.SEAT_LEFT2_INDEX            = 1                                 --左二
cmd.SEAT_LEFT3_INDEX            = 2                                 --左三
cmd.SEAT_LEFT4_INDEX            = 3                                 --左四
cmd.SEAT_RIGHT1_INDEX           = 4                                 --右一
cmd.SEAT_RIGHT2_INDEX           = 5                                 --右二
cmd.SEAT_RIGHT3_INDEX           = 6                                 --右三
cmd.SEAT_RIGHT4_INDEX           = 7                                 --右四
cmd.MAX_OCCUPY_SEAT_COUNT       = 8                                 --最大占位个数
cmd.SEAT_INVALID_INDEX          = 9                                 --无效索引

--空闲状态
cmd.GAME_SCENE_FREE				= 0
--游戏开始
cmd.GAME_START 					= 1
--游戏进行
cmd.GAME_PLAY					= 100
--下注状态
cmd.GAME_JETTON					= 100
--游戏结束
cmd.GAME_END					= 101

--游戏倒计时
cmd.kGAMEFREE_COUNTDOWN			= 1
cmd.kGAMEPLAY_COUNTDOWN			= 2
cmd.kGAMEOVER_COUNTDOWN			= 3

cmd.MAX_OCCUPY_SEAT_COUNT = 6
cmd.SCORE_NUMS = 5

---------------------------------------------------------------------------------------
--服务器命令结构

--游戏空闲
cmd.SUB_S_GAME_FREE				= 99
--游戏开始
cmd.SUB_S_GAME_START			= 100
--用户下注
cmd.SUB_S_PLACE_JETTON			= 101
--游戏结束
cmd.SUB_S_GAME_END				= 102
--更新积分
cmd.SUB_S_CHANGE_USER_SCORE		= 105
--游戏记录
cmd.SUB_S_SEND_RECORD			= 106
--下注失败
cmd.SUB_S_PLACE_JETTON_FAIL		= 107
--管理员命令
cmd.SUB_S_AMDIN_COMMAND			= 109
--更新库存
cmd.SUB_S_UPDATE_STORAGE		= 110
--发送下注(服务端消息)
cmd.SUB_S_SEND_USER_BET_INFO    = 111
--发送下注(服务端消息)
cmd.SUB_S_USER_SCORE_NOTIFY     = 112
--某条记录的详细信息
cmd.SUB_S_SEND_ITEMRECORD       = 113
--请求10条记录
cmd.SUB_S_SEND_GAMERECORD       = 114
--请求用户下注记录
cmd.SUB_S_SEND_ADDBETRECORD     = 115
--更新占位
cmd.SUB_S_UPDATE_OCCUPYSEAT     = 118
---------------------------------------------------------------------------------------

--会员
cmd.VIP1_INDEX = 1;
cmd.VIP2_INDEX = 2;
cmd.VIP3_INDEX = 3;
cmd.VIP4_INDEX = 4;
cmd.VIP5_INDEX = 5;
cmd.VIP_INVALID = 6;

--下注失败
cmd.CMD_S_PlaceBetFail =
{
	--下注玩家
	{k = "wPlaceUser", t = "word"},
	--下注区域
	{k = "cbBetArea", t = "byte"},
	--下注数额
	{k = "lPlaceScore", t = "score"}
}

--游戏状态 free
cmd.CMD_S_StatusFree = 
{
	--剩余时间
	{k = "cbTimeLeave", t = "byte"},
    {k = "dwBetScore", t = "dword", l = {cmd.SCORE_NUMS}},           --下注额度列表
    --房间信息 SERVER_LEN
    {k = "szGameRoomName", t = "string", s = cmd.SERVER_LEN},					--房间名称
    {k = "bGenerEducate", t = "bool"},	                             --是否练习场					
}

--游戏状态 play/jetton
cmd.CMD_S_StatusPlay = 
{
	--全局信息					
    {k = "cbTimeLeave", t = "byte"},					--剩余时间					
    {k = "dwBetScore", t = "dword", l = {cmd.SCORE_NUMS}},           --下注额度列表
    {k = "cbGameStatus", t = "byte"},					--游戏状态
    {k = "cbAllTime", t = "byte"},                      --总时间
    --下注数 AREA_MAX						
    {k = "lAllBet", t = "score", l = {cmd.AREA_TYPE,cmd.AREA_MAX}},	--总下注		
    {k = "lPlayBet", t = "score", l = {cmd.AREA_TYPE,cmd.AREA_MAX}},	--玩家下注
    {k = "lPlayBetScore", t = "score"},					--玩家最大下注	
    --玩家输赢 AREA_MAX
    {k = "lPlayScore", t = "score", l = {cmd.AREA_TYPE,cmd.AREA_MAX}},--玩家输赢
    {k = "lPlayAllScore", t = "score"},                 --玩家成绩
    {k = "lRevenue", t = "score"},						--税收

    --开奖号码
    {k = "openNum", t = "byte"},

    --房间信息 SERVER_LEN
    {k = "szGameRoomName", t = "tchar", s = cmd.SERVER_LEN},	--房间名称
    {k = "bGenerEducate", t = "bool"},	                         --是否练习场
    {k = "wOccupySeatChairIDArray", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}}, --占位椅子ID
}

--游戏空闲
cmd.CMD_S_GameFree = 
{
    {k = "cbTimeLeave", t = "byte"}
}

--游戏开始
cmd.CMD_S_GameStart = 
{
    --剩余时间
    {k = "cbTimeLeave", t = "byte"},    
    --玩家最大下注
    {k = "lPlayBetScore", t = "score"},    
    --人数上限 (下注机器人)
    {k = "nChipRobotCount", t = "int"},
    --列表人数
    {k = "nListUserCount", t = "int"},
    --机器人列表人数
    {k = "nAndriodCount", t = "int"},
}

--用户下注
cmd.CMD_S_PlaceBet = {
    {t='word',      k='wChairID',            },                         --用户位置
    {t='byte',      k='cbBetType',           },                         --筹码类别
    {t='byte',      k='cbBetArea',           },                         --筹码区域
    {t='score',     k='lBetScore',           },                         --加注数目
    {t='byte',      k='cbAndroidUser',       },                         --机器标识
    {t='byte',      k='cbAndroidUserT',      },                         --机器标识
}

--游戏结束
cmd.CMD_S_GameEnd = 
{
    --下局信息
    --剩余时间
    {k = "cbTimeLeave", t = "byte"},
    
    --开奖号码
    {k = "openNum", t = "byte"},
    
    --玩家成绩 AREA_MAX
    {k = "lPlayScore", t = "score", l = {cmd.AREA_TYPE,cmd.AREA_MAX}},

    --玩家成绩
    {k = "lPlayAllScore", t = "score"},

    --游戏税收
    {k = "lRevenue", t = "score"},
    --VIP玩家成绩
    {k = "lPlayOtherScore", t = "score",l = {cmd.MAX_OCCUPY_SEAT_COUNT}},
}

--主界面记录信息,106消息携带
--tagServerOpenGameRecord
cmd.CMD_S_ServerOpenGameRecord = 
{
    --记录条数
    {k = "openNumCount", t = "int"},
    --页数,从0开始
    {k = "openNum", t = "byte", l = {cmd.MAX_SCORE_HISTORY}}
}

cmd.tagaddBetUser =
{
    --玩家名字
    {k = "betUserName", t = "string", s = cmd.LEN_NICKNAME},
    --玩家分数
    {k = "betScore", t = "score", l = {cmd.AREA_MAX}},
    --玩家输赢
    {k = "betWinScore", t = "score", l = {cmd.AREA_MAX}},
}

--获取某条详细记录信息返回
cmd.CMD_S_GetRecordItem = 
{
    --记录条数,从0开始
    {k = "itemIndex", t = "byte"},
    --页数,从0开始
    {k = "startpage", t = "int"},
    --每页多少条
    {k = "pagesize", t = "int"},
    --总页数
    {k = "totalcount", t = "int"},
    --总条数
    {k = "recordcount", t = "int"},
    {k = "openNum", t = "byte"},
    {k = "openTimer", t = "score"},
    {k = "recordgamebet", t = "table", d = cmd.tagaddBetUser},
}

cmd.tagServerGameRecord =
{
    --服务器种子
    {k = "cbSeverSeed", t = "string", s = cmd.SERVER_SEEDLEN},
    --开奖号码
    {k = "openNum", t = "byte"},
    --开奖时间戳
    {k = "openTimer", t = "score"},
    --开奖记录索引,从0开始
    {k = "itemIndex", t = "score"},
}

--请求10条记录返回
--tagServerGameRecord
cmd.CMD_S_ServerGameRecord =
{
    {k = "totalcount", t = "byte"}, --记录总数
    {k = "serverTimer", t = "score"}, --服务器当前时间
    {k = "gameRecord", t = "table", d = cmd.tagServerGameRecord, l = {cmd.MAX_PAGE_COUNT}},
}

cmd.tagAddUserBetInfo =
{
    {k = "chairId", t = "word"}, --椅子id
    {k = "betScore", t = "score", l = {cmd.AREA_TYPE,cmd.AREA_MAX}},
}

--进游戏或重连时推送当前所有玩家下注消息
cmd.CMD_S_Server_AddBet =
{
    -- {k = "count", t = "int"}, --玩家总数
    {k = "addUserBetInfo", t = "table", d = cmd.tagAddUserBetInfo,}-- l = {cmd.GAME_PLAYER}},
}

--更新占位
cmd.CMD_S_UpdateOccupySeat =
{
    --无效占位id为65535
    {k = "wOccupySeatChairIDArray", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}} --占位椅子ID
}

---------------------------------------------------------------------------------------
--客户端命令结构

--用户下注
cmd.SUB_C_PLACE_JETTON				= 1
--管理员命令
cmd.SUB_C_AMDIN_COMMAND				= 4
--更新库存
cmd.SUB_C_UPDATE_STORAGE			= 5
--请求某条记录的详细信息
cmd.SUB_C_SEND_ITEMRECORD           = 6
--请求10条记录
cmd.SUB_C_SEND_GAMERECORD           = 7
---------------------------------------------------------------------------------------
--用户下注
cmd.CMD_C_PlaceBet = {
  {t='score',     k='lBetScore',           },                         --加注数目
  {t='byte',      k='cbBetType',           },                         --0到 4   0  单数投注 ----4  e.特殊组合
  --区域说明：
  --单数： 1 ~ 12                        12个， 依次传：0~11                  cbBetType类型 = 0
  --双数： 1|2 ~ 11|12                   16个， 依次传：0~15                  cbBetType类型 = 1
  --4个数：1|2|3|4 ~ 9|10|11|12          5个，  依次传：0~4                   cbBetType类型 = 2
  --6个数：1-6, Even, 红, 黑, Odd, 7~12  6个，  依次传：0~5                   cbBetType类型 = 3
  {t='byte',      k='cbBetArea',           },                         --筹码区域 0-15 区域 
  {t='byte',      k='cbCount',             },
}
--获取某条详细记录
cmd.CMD_C_GetRecordItem = {
    {t='score',     k='itemIndex',           },                         --筹码区域
    {t='int',       k='startpage',           },                         --页数 从0开始
    {t='int',       k='pagesize',            },                         --每页多少条
}
  


cmd.RES_PATH 					= 	"double/res/"
print("********************************************************load cmd");
return cmd