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
cmd.KIND_ID						= 803
	
--游戏人数
cmd.GAME_PLAYER					= 4

cmd.MAX_POKER_COUNT             =  24
cmd.MAX_PLAYER_COUNT            =  4

cmd.MAX_POINT_COUNT             =  15 --每种花色13张 2-A(14)

--花色
cmd.CARD_TYPE_SPADE             = 0
cmd.CARD_TYPE_HEART             = 1
cmd.CARD_TYPE_CLUB              = 2
cmd.CARD_TYPE_DIAMOND           = 3
cmd.MAX_TYPE_COUNT              = 4


--可更新的牌区
cmd.POKER_AREA_DISCARD          = 1
cmd.POKER_AREA_PUT              = 2
cmd.POKER_AREA_HAND             = 3

cmd.SUB_C_CMD_ENTER             = 1       -- 进入桌子
cmd.SUB_C_CMD_READY             = 2       -- 坐下准备好
cmd.SUB_C_CMD_LEAVE             = 3       -- 离开

---------------------------------------------------------------------------------------
--游戏状态
--空闲状态
cmd.GAME_SCENE_FREE				= 0
--游戏开始
cmd.GAME_START 					= 1
--游戏进行
cmd.GAME_PLAY					= 100
--应答时候的状态，此时不能出牌，发的字段同play
cmd.GAME_CALL				    = 101
--11分的状态，发的字段同play
cmd.GAME_WAIT					= 102
--truco等叫分时的状态，发的字段同play
cmd.GAME_SHOW                   = 103
--游戏结束
cmd.GAME_END                    = 104
---------------------------------------------------------------------------------------

--游戏倒计时
cmd.kGAMEFREE_COUNTDOWN			= 1
cmd.kGAMEPLAY_COUNTDOWN			= 2
cmd.kGAMEOVER_COUNTDOWN			= 3

---------------------------------------------------------------------------------------
--服务器命令字段
cmd.SUB_S_GAME_SITDOWN          = 99    -- 坐下
cmd.SUB_S_GAME_READY            = 100   -- 准备
cmd.SUB_S_GAME_START            = 101   -- 开始
cmd.SUB_S_GAME_DEAL             = 102   -- 发牌
cmd.SUB_S_GAME_OP_FAILD         = 103   -- 操作失败(非法操作),没用到
cmd.SUB_S_GAME_UPDATE_SCORE     = 104   -- 更新分值,没用到
cmd.SUB_S_GAME_UPDATE_ACTION    = 105   -- 更新动作action
cmd.SUB_S_CMD_GET               = 111   -- 摸牌:谁摸了牌,没用到
cmd.SUB_S_CMD_DISCARD           = 112   -- 出牌
cmd.SUB_S_GAME_NEXT_TURN        = 113   -- 没用到
cmd.SUB_S_CMD_TRUCO             = 114
cmd.SUB_S_CMD_ANSWERTRUCO       = 115
cmd.SUB_S_CMD_SHOW_CARD         = 116
cmd.SUB_S_CMD_TIMER             = 118   -- 更新读秒倒计数,没用到
cmd.SUB_S_GAME_END              = 119
cmd.SUB_S_GAME_TURN_END         = 120   -- 一轮结束
cmd.SUB_S_CMD_CONTINUE_GAME     = 121   -- 11分临界情况是否继续
cmd.SUB_S_SHOW_FRIEND_CARD      = 122   -- 显示队友的牌
cmd.SUB_S_GAME_CALLTRUCO_STATUS = 123   -- 重连的时候已做的更新动作
cmd.SUB_S_USERTRUSTEE           = 124   -- 托管消息,只会发给自己，其他玩家不展示
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--客户端命令字段
cmd.SUB_C_CMD_GET               = 10   -- 摸牌
cmd.SUB_C_CMD_DISCARD           = 11   -- 出牌
cmd.SUB_C_CMD_GIVEUP            = 12   -- 弃牌
cmd.SUB_C_CMD_TRUCO             = 13   -- TRUCO 
cmd.SUB_C_CMD_ANSWERTRUCO       = 14   -- 应答TRUCO 
cmd.SUB_C_CMD_SHOW_CARD         = 15   -- 亮底牌
cmd.SUB_C_CMD_CONTINUE_GAME     = 16   -- 11分临界情况是否继续
cmd.SUB_C_USERTRUSTEE           = 17   -- 托管/取消托管请求
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--服务端命令结构
-- 发牌
cmd.CMD_S_GAME_DEAL = 
{
	{k = "playerCount", t = "byte"},                         --玩家人数
    {k = "restCardsCount", t = "byte"},                      --剩余牌数
    {k = "banker", t = "byte"},                              --庄家
    {k = "dealCount", t = "byte"},					         --发牌的数量(3涨)
    {k = "pokers", t = "byte", l = {cmd.POKER_AREA_HAND}},	 --我自己的牌(最大只可能3张)
    {k = "magicCard", t = "byte"},                           --公开牌
    {k = "isNext", t = "byte"},                              --是否下一轮,0是最新发牌，1是一局结束重新发牌,最新发牌有vs动画
    {k = "currentChairID", t = "byte"},                      --轮到操作玩家,出牌的玩家
    {k = "IsCanCall", t = "byte"},                           --是否能叫分,走action，没用到
}

-- 应答truco操作返回
cmd.CMD_S_AnswerTruco = 
{

    {k = "chairID", t = "byte"},                         --座位号
    {k = "TrucoScore", t = "byte"},                      --分数,1放弃 2 跟 3 加倍
    {k = "TeamTrucoScore", t = "byte"},                  --同上，队友的操作
    {k = "CurrentScore", t = "byte"},                    --当前的分数,非truco后的分数
    {k = "CurrentTrucoScore", t = "byte"},               --当前truco后的分数
    {k = "currentChairID", t = "byte"},                  --轮到操作玩家,出牌的玩家
    {k = "IsCanCall", t = "byte"},                       --是否能叫分,暂没用到
    {k = "IsAnswerTrucoFinish", t = "byte"},             --是否应答完成,两个人都完成应答,0没完成，1完成
    {k = "MaxTrucoScore", t = "byte"},                   --暂没用到,一般是12分
    {k = "trucoTimes", t = "byte"},                      --总的truco次数
}

-- truco操作返回
cmd.CMD_S_Truco = 
{
    {k = "chairID", t = "byte"},                         --座位号，谁叫的truco
    {k = "TrucoScore", t = "byte"},                      --分数，0--放弃 1--Truco
    {k = "CurrentScore", t = "byte"},                    --当前的分数,非truco后的分数
    {k = "CurrentTrucoScore", t = "byte"},               --当前truco后的分数
    {k = "currentChairID", t = "byte"},                  --轮到操作玩家,出牌的玩家，非truco
    {k = "IsCanCall", t = "byte"},                       --是否能叫分,没用到
}

-- 出牌返回
cmd.CMD_S_GAME_DISCARD = 
{
    {k = "chairID", t = "byte"},                         --座位号
    {k = "card", t = "byte"},                            --牌值
    {k = "currentChairID", t = "byte"},                  --轮到操作玩家,出牌的玩家
    {k = "IsCallTruco", t = "byte"},                     --是否已经叫过分,没用到
    {k = "isHide", t = "byte"},                          -- 是否隐藏牌,0不隐藏，1隐藏
}

--亮牌返回
cmd.CMD_S_ShowCard = 
{
    {k = "chairID", t = "byte"},                         --座位号
    --手牌
    {k = "HandleCard", t = "byte", l = {cmd.POKER_AREA_HAND}},
}

--11分临界情况服务器推送队友牌
cmd.CMD_S_FriendShowCard =
{
    {k = "chairID", t = "byte"},                         --座位号
    {k = "HandleCard", t = "byte", l = {cmd.POKER_AREA_HAND}},
}

cmd.CMD_S_ContinueGame =
{
    {k = "chairID", t = "byte"},                    --座位号
    {k = "isFinish", t = "byte"},                   --是否完成选择，0未完成，1完成
    {k = "ContinueGameStatus", t = "byte"},         --chairID做的选择
    {k = "FriendContinueGameStatus", t = "byte"},   --chairID的队友做的选择
}

--游戏状态 free
cmd.CMD_S_StatusFree =
{
    {k = "cbTimeLeave", t = "byte"},                                --剩余时间
    {k = "lCellScore", t = "score"},                                --房间底分
    {k = "trucoTimes", t = "byte"},                                 --总的truco次数
    {k = "showCardBtnTime", t = "byte"},                            --亮牌按钮显示时间
}

--游戏状态 play/jetton
cmd.CMD_S_StatusPlay =
{
	--全局信息
    {k = "cbTimeLeave", t = "byte"},					            --剩余时间
    {k = "cbGameStatus", t = "byte"},					            --游戏状态
    {k = "cbAllTime", t = "byte"},                                  --总时间
    {k = "lRevenue", t = "score"},						            --税收

    {k = "HandleCount", t = "int", l = {cmd.GAME_PLAYER}},          --手牌数量，对应座位号
    {k = "pokers", t = "byte", l = {cmd.POKER_AREA_HAND}},          --我自己的牌(最大只可能3张)
    {k = "magicCard", t = "byte"},                                  --公开牌
    {k = "Score", t = "byte", l = {cmd.POKER_AREA_PUT}},            --两队的分数, 序号0偶数队分数 1奇数队分数,与自己的chairId对比
    {k = "isNext", t = "byte"},                                     --是否下一轮,0是最新发牌，1是一局结束重新发牌
    {k = "currentChairID", t = "byte"},                             --轮到操作玩家,出牌的玩家
    {k = "IsCanCall", t = "byte"},                                  --是否能叫分,没用到
    {k = "WinRoundCount", t = "byte", l = {cmd.POKER_AREA_HAND}},   --值为1奇数位置赢 2偶数位置赢 0一样大,与自己的chairId对比
    {k = "MaxRoundCount", t = "byte"},                              --当前轮
    {k = "bBigCard", t = "byte"},                                   --最大的牌
    {k = "bRoundCard", t = "byte", l = {cmd.GAME_PLAYER}},          --四个座位出的牌，非0就有牌,非0可能是隐藏牌，看总数做最后确定
    {k = "bTrunCardCount", t = "byte"},                             --当前出牌总共出了多少张
    {k = "banker", t = "byte"},                                     --庄家
    {k = "curScore", t = "byte"},                                   --当前分
    {k = "lCellScore", t = "score"},                                --房间底分,注意，底分是金币值，其他分是当局叫分值
    {k = "trucoTimes", t = "byte"},                                 --总的truco次数
    {k = "firstOutPlayer", t = "byte"},                             --首次出牌的玩家chairid
    {k = "showCardBtnTime", t = "byte"},                            --亮牌按钮显示时间
    {k = "UserTrustee", t = "byte"},                                --状态1托管 0 取消
}

cmd.CMD_S_PlayerCallScoreAction =
{
    {k = "TrucoChairID", t = "byte"},                               --第一个发起truco的id
    {k = "TrucoScore", t = "byte"},                                 --0放弃 1 叫
    {k = "AnswerTrucoAct", t = "byte", l = {cmd.GAME_PLAYER}},      --1放弃 2 跟 3 加倍,跟chairid对应, 0为没有值
    {k = "AnswerTrucoScore", t = "byte", l = {cmd.GAME_PLAYER}},    --当前应答分数,跟chairid对应(值为3,6,9,12)0没值
    {k = "CurrentTrucoScore", t = "byte"},                          --当前truco后的分数
}

--一轮结束,展示最大的牌
cmd.CMD_S_RoundGameEnd =
{
    {k = "bBigCard", t = "byte"},                                   --最大的牌
    {k = "bTrunCardCount", t = "byte"},                             --当前出牌总共出了多少张
    {k = "bRoundCard", t = "byte", l = {cmd.GAME_PLAYER}},          --四个座位出的牌，非0就有牌
    {k = "Score", t = "byte", l = {cmd.POKER_AREA_PUT}},            --两队的分数, 序号0偶数队分数 1奇数队分数,与自己的chairId对比
    {k = "WinRoundCount", t = "byte", l = {cmd.POKER_AREA_HAND}},   --值为1奇数位置赢 2偶数位置赢 0一样大,与自己的chairId对比
    {k = "MaxRoundCount", t = "byte"},                              --当前轮
    {k = "IsCurRoundOver", t = "byte"},                             --当前局是否结束, 0没结束，1结束了
}

--底部按钮操作消息,cmd.SUB_S_GAME_UPDATE_ACTION
--对家truco，会收到两条消息，一条chairid是我，一条是队友
cmd.CMD_S_DummePlayerAction =
{
    {k = "chairID", t = "byte"},                            --座位号
    {k = "cbAllTime", t = "byte"},                          --总秒数
    {k = "seconds", t = "byte"},                            --秒数
    {k = "curScore", t = "byte"},                           --当前分
    {k = "nextCallScore", t = "byte"},                      --下一次叫分
    {k = "CanTruco", t = "bool"},                           --Truco
    {k = "CanAumentar", t = "bool"},                        --加倍
    {k = "CanCorrer", t = "bool"},                          --认输
    {k = "CanAceitar", t = "bool"},                         --接受
    {k = "CanShowCard", t = "bool"},                        --显示牌
    {k = "CanGiveUp", t = "bool"},                          --弃牌，同认输
    {k = "CanOutCard", t = "bool"},                         --出牌
    {k = "wCurChairID", t = "byte"},                        --机器人使用，没用到的座位号
    {k = "CanWaitContinue", t = "bool"},                    --等待继续,只有11分临界情况时为true
    {k = "CanGiveUpContinue", t = "bool"},                  --放弃开始游戏,只有11分临界情况时为true
}

--游戏空闲
cmd.CMD_S_GameFree =
{
    {k = "cbTimeLeave", t = "byte"}
}

--游戏结束
cmd.CMD_S_GameEnd = 
{
    {k = "cbTimeLeave", t = "byte"},                            --剩余时间
    {k = "lPlayAllScore", t = "score", l = {cmd.GAME_PLAYER}},  --玩家成绩
    {k = "lRevenue", t = "score", l = {cmd.GAME_PLAYER}},       --游戏税收
}

cmd.CMD_S_Usertrustee =
{
    {k = "chairID", t = "byte"},                            --座位号
    {k = "trustee", t = "byte"},                            --1托管 0 取消
}
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--客户端发送命令结构
--出牌
cmd.CMD_C_GAME_DISCARD =
{
	{k = "isHide", t = "byte"},        -- 是否隐藏牌,0不隐藏，1隐藏
	{k = "card", t = "byte"}           -- 出牌的牌值
}

--认输
cmd.CMD_C_GiveUp =
{
}

--主动发起truco
cmd.CMD_C_Truco =
{
    --0放弃 1 Truco
    {k = "TrucoScore", t = "byte"}
}

--应答truco
cmd.CMD_C_AnswerTruco =
{
    --1放弃 2 跟 3 加倍
    {k = "TrucoScore", t = "byte"}
}

--一局结束亮牌
cmd.CMD_C_ShowCard =
{
}

--11分临界选择是否继续
cmd.CMD_C_ContinueGame =
{
    {k = "isContinue", t = "byte"} --1放弃 2 继续
}

cmd.CMD_C_Usertrustee =
{
    {k = "trustee", t = "byte"},      --1托管 0 取消
}

---------------------------------------------------------------------------------------

cmd.RES_PATH 					= 	"truco/res/"
print("********************************************************load cmd");
return cmd