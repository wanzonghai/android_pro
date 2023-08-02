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
cmd.KIND_ID						= 532
	
--小玛利选择数量
cmd.BONUS_MAX					= 3

--最大20连线
cmd.MAX_LINE                    = 20
cmd.MAX_HS                      = 3   -- 最大行数
cmd.MAX_LS                      = 5   -- 最大列数

--[[local icon_id = {
    YinBi     = 0,-- 银币
    HongBao   = 1,-- 红包
    PaoZhu    = 2,-- 炮竹
    TaoZi     = 3,-- 桃子
    DengLong  = 4,--灯笼
    YuanBao   = 5,-- 元宝
    JinYu     = 6,--金鱼
    JinZhuan  = 7,--金砖
    Yu        = 8,--玉
    ShiTou    = 9,--狮头
    WILD      = 10,-- WILD             //百搭
    WaWa      = 11,-- 娃娃           只出现在2 3 4 列  中奖送免费次数
    CaiShen   = 12,-- 财神 1,3,5
}--]]
cmd.itemType = {
    eNone = 0,   
    ePokerTen = 1,
    ePokerJ = 2,  
    ePokerQ = 3,  
    ePokerK = 4,
    ePokerA = 5,
    eBird = 6,
    eWolf = 7,
    eBear = 8,
    eDiamond = 9,
    eBoat = 10,
    eSnowGirl = 11,
}
cmd.modeType = {
    eNone = 0,   
    eNormal = 1,
    eBonus = 2,  
    eFree = 3,  
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
cmd.SUB_S_SCENE1_START                 = 100             -- 滚动结果
cmd.SUB_S_HIT_GOLDEGG_RES                = 105             -- 玛丽结果
cmd.SUB_GAME_CONFIG                    = 104             --服务配置
cmd.SUB_S_USER_DATA                    = 107             --用户赢分反馈（主要处理其他人，暂时未用到）   
cmd.SUB_S_GOLDEGG_DETAIL                = 108             -- 小玛利结算 
---------------------------------------------------------------------------------------
--滚动结果
cmd.CMD_S_Scene1Start = {
    { t="byte", k="bouns_status_"},        --大于0代表触发小玛利未用到了，改用game_mode判断
    { t="int", k="frees_count"},       --免费游戏次数
    { t="int", k="frees_max"},       --免费游戏最大次数
    { t="int", k="frees_cur"},       --当前轮触发的免费游戏次数
    { t="score", k="lWinScore"},        --输赢金币
    { t="score", k="lScore", },       --总赢分
    { t="byte", k="game_mode"},       --用户状态
    { t="byte", k="zJLineArray", l={cmd.MAX_LINE}}, --中奖线
    { t="byte", k="result_icons", l={cmd.MAX_HS, cmd.MAX_LS}}, --中奖结果
    { t="dword",k="dwHashID"},
    { t="dword",k="dwCRC"},
}
--玛丽结果
cmd.Cmd_S_HitGoldEggRes = {
    { t="int", k="nResult", },       --0正常成功 1表示此位置已经被点击过 2 位置不对
    { t="int", k="nHitPos", }, --选择序号
    { t="int", k="nAwardMultiply", }, --赢分倍数
    { t="int", k="nLeftHitFreeCount", }, --剩余次数
    --{ t="score", k="lWinScore3", },       --赢分
    --{ t="score", k="lScore3", },       --总赢分
    --{ t="score", k="lBounsWinScore", l={6}},   --奖金
}
--玛丽结算
cmd.Cmd_S_GoldEggDetail = {
    { t="score", k="lWinScore3", },       --赢分
    { t="score", k="lScore3", },       --总赢分
    { t="int", k="lBounsMultiply", l={6}},   --奖金倍数
    --{ t="score", k="lBounsWinScore", l={6}},   --奖金
}
--服务配置
cmd.CMD_S_GameConfig = {
    { t="byte", k="game_version"},                        -- kGameVersion的值
    { t="int",  k="betArray", l={10}},
} 
--用户赢分反馈（主要处理其他人，暂时未用到）
cmd.CMD_S_User_data ={
    {t="bool",  k="bScatter"},  -- 是否在免费次数
    {t="bool",  k="bBouns"},    -- 是否在bouns
    {t="word", k="wChairID"},
    {t="score", k="lWinScore"}, -- 赢分
    {t="score", k="userScore"}, -- 用户身上金币
}
--场景数据
cmd.CMD_S_SCENE_Data = { 
    { t="byte",       k="cbYaXianCount"},                  --总压线
    { t="byte",       k="game_mode"},                  --用户状态--3小玛利
    { t="byte",       k="bouns_count"},                  --/小玛莉
    { t="int",       k="frees_count"},                  --/免费游戏次数
    { t="int",       k="frees_max"},       --免费游戏最大次数
    { t="int",       k="frees_cur"},       --当前轮触发的免费游戏次数
    { t="score",      k="lWinScore"},                     --输赢金币
    { t="byte",       k="zJLineArray", l={cmd.MAX_LINE}}, --开奖结果
    { t="byte",       k="result_icons", l={cmd.MAX_HS, cmd.MAX_LS}},   --中奖结果
    { t="byte",       k="bonus_step"},                  --小玛利已选水晶数量
    { t="score",      k="lBounsWinScore_old", l={3}}, -- bouns总赢分之前的逻辑未用到了未用到了未用到了
    { t="score",      k="win_score", l={1}}, -- 总赢分数组只有自己
    { t="int",        k="lBounsWinScore", l={6}}, -- 水晶分值数组未开是0
    { t="score",      k="lFreeTotalAward"},                     --免费游戏输赢金币
    { t="dword",      k="dwHashID"},
    { t="dword",      k="dwCRC"},
}

---------------------------------------------------------------------------------------
--客户端命令结构
cmd.SUB_C_SCENE1_START                  =3               --开始旋转
cmd.SUB_C_HIT_GOLDEGG                  =12               --小玛莉选择序号
cmd.CMD_C_Scene1Start = {
    { t="byte", k="total_AddCount", },                  --总下注
}
cmd.CMD_C_HitGoldEgg = {
    { t="int", k="nHitPos"}, -- 0开始，顺序从左到右
}

---------------------------------------------------------------------------------------


cmd.RES_PATH 					= 	"snowwomen/res/"
print("********************************************************load cmd");
return cmd