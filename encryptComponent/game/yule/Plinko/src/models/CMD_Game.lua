
local cmd = {}

--游戏版本
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 901
--游戏人数
cmd.GAME_PLAYER					= 1

cmd.MAX_BET_INDEX = 15

--命令定义
cmd.SUB_C_START				          = 1										--OK 普通游戏开始 
cmd.SUB_C_SEND_GAMERECORD       = 2                    --游戏记录
cmd.SUB_C_SEND_ROUTE            = 3                    --上传路径

cmd.SUB_S_GAME_START				    =100									--OK 普通游戏开始 广播数据
cmd.SUB_S_GAME_CONCLUDE				  =101									--OK 普通游戏结束
cmd.SUB_S_USER_DATA					    =102									--OK 用户信息
cmd.SUB_S_SEND_GAMERECORD       =103                  --游戏记录
cmd.UB_S_SEND_ROUTE             = 104                  --关播路径
cmd.SUB_S_CALCULATE_ROUTE       = 105                 -- 服务端请求某位玩家计算路径


cmd.CMD_C_OneStart = {
    {t='byte',      k='lBetIndex'  },                         --下注下标 0-14
    {t='byte',      k='cbLineType' },                         --LINETYPE：选择押的哪条线
    {t='byte',      k='lMode'      },                         --EGAMEMODE:绿黄红
  }
  

cmd.CMD_S_GameSceneStatus = {
    {t='score',     k='lCellScore' },                         --基础积分
    {t='score',     k='lWinScore'  },                         --输赢金币
    {t='byte',      k='cbBetIndex' },                         --当前压的第几倍下标 0-14
    {t='byte',      k='cbMaxBetCount'},                       --最大可下注数量
    {t='byte',      k='cbAutoDelayTime'},                       --自动下注频率  cbAutoDelayTime/10 秒一次
    {t='score',     k='lBetScore',l={cmd.MAX_BET_INDEX}},            --下注大小
    {t='word',      k='nLinesMultiples12',l = {3,7}},    --12线：整体乘于了10，显示的时候需要除于10.0f,数组分别为绿黄红的赔率
    {t='word',      k='nLinesMultiples14',l = {3,8}},    --14线：整体乘于了10，显示的时候需要除于10.0f,数组分别为绿黄红的赔率
    {t='word',      k='nLinesMultiples16',l = {3,9}},    --16线：整体乘于了10，显示的时候需要除于10.0f,数组分别为绿黄红的赔率
    {t='word',      k='nAutoRunCount',l = {6}},    --自动投注的可选项配置
  }
  
  cmd.CMD_S_User_data = {
    {t='word',      k='wChairID'   },                         
    {t='score',     k='lWinScore'  },                         --赢分
    {t='score',     k='userScore'  },                         --用户身上金币
  }
  

-- 上传路线 和 广播数据
cmd.CMD_S_RouteResult = {
  {t='word',      k='wChairID'   },                         --玩家ID
  {t='score',     k='win_score'  },                         --输赢金币
  {t='byte',      k='cbItemIndex'},                         --开奖信息(倍数下标)
  {t='byte',      k='cbLineType' },                         --选择押的哪条线 LINETYPE
  {t='byte',      k='cbGameMode' },                         --游戏模式
  {t='byte',      k='cbBetIndex' },                         --当前选择的下注索引
  {t='byte',      k='routes',l = {16} },                         --路径
}

-- --请求算路线
-- cmd.CMD_S_CalculateRoute = {
--   {t='word',      k='wChairID'   },                         --玩家ID
--   {t='score',     k='win_score'  },                         --输赢金币
--   {t='byte',      k='cbItemIndex'},                         --开奖信息(倍数下标)
--   {t='byte',      k='cbLineType' },                         --选择押的哪条线 LINETYPE
--   {t='byte',      k='cbGameMode' },                         --游戏模式
--   {t='byte',      k='cbBetIndex' },                         --当前选择的下注索引
-- }

return cmd