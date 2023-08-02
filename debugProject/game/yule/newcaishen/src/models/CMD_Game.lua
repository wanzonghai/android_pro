

local cmd = {
    KIND_ID = 529,
    GAME_PLAYER = 5,
    MAX_LINE = 50, --最大50连线
    MAX_HS = 3,   -- 最大行数
    MAX_LS = 5,   -- 最大列数
    SUB_S_SCENE2_RESULT                = 101,             -- 骰子结果
    SUB_S_SCENE3_RESULT                = 102,             -- 玛丽结果
    SUB_S_SCENE1_START                 = 100,             -- 滚动结果
    SUB_S_STOCK_RESULT                 = 103, 
    SUB_GAME_CONFIG                    = 104,             --服务配置
    SUB_S_USER_DATA            = 107,   

    GAME_SCENE_PART1      = 101,         --   // 第1部分
    GAME_SCENE_PART2      = 102,      --// 第2部分
    GAME_SCENE_PART3      = 103,      --// 第3部分
    
    --2级游戏命令  小玛丽
    SUB_C_HIT_GOLDEGG   = 6,          --敲击金蛋
    SUB_S_HIT_GOLDEGG_RES = 105,      --敲金蛋返回

    SUB_S_GOLDEGG_DETAIL=108,         --敲完5个后服务器推送其他罐子数据
}

--场景配置
cmd.CMD_S_GameConfig = {
    { t="byte", k="game_version"},                        -- kGameVersion的值
    { t="int",  k="betArray", l={10}},
    { t="score", k="llsmall", },       -- 爆分动画 小
    { t="score", k="llmiddle", },      -- 中
    { t="score", k="llbig", },         -- 大
}    

--场景数据，断线重连
cmd.CMD_S_SCENE_Data = { 
    { t="byte",       k="bet_score"},                  --总压线
    { t="byte",       k="bGameModes"},                  --场景状态  1：普通  2：开罐子 3：免费
    { t="byte",       k="bouns_count"},                  --/小玛莉
    { t="score",      k="win_score"},                     --输赢金币
    { t="byte",       k="zJLineArray", l={cmd.MAX_LINE}}, --开奖结果
    { t="byte",       k="result_icons", l={cmd.MAX_HS, cmd.MAX_LS}},   --中奖结果
    { t="byte",       k="bonus_step"},                  --总压线
    { t="score",      k="lBounsWinScore", l={5}}, -- bouns总赢分
    { t="score",      k="win_score", l={1}}, -- bouns总赢分
    { t="dword",      k="dwHashID"},
    { t="dword",      k="dwCRC"},
    { t="score",      k="nFreeTotalAwardGold", }, -- 小玛丽已有的赢分
    
    { t="int",        k="frees_count"},                  --/免费游戏次数
    { t="int",        k="all_frees_count"},   --总的免费游戏次数
    { t="int",        k="cur_get_frees_count"},  --当前次获取免费游戏次数
    {t='int',         k='nMultiply',l = {12}},               
    {t='int',         k='nGoldWealth',l = {12}},   
}

cmd.CMD_S_User_data ={
    {t="bool",  k="bScatter"},  -- 是否在免费次数
    {t="bool",  k="bBouns"},    -- 是否在敲蛋小玛丽
    {t="word", k="wChairID"},
    {t="score", k="lWinScore"}, -- 赢分
    {t="score", k="userScore"}, -- 用户身上金币
}

 -------------------------------------------------------------------------------
-- 客户端命令

cmd.SUB_C_ADD_CREDIT_SCORE              =1               -- 上分
cmd.SUB_C_REDUCE_CREDIT_SCORE           =2               -- 下分
cmd.SUB_C_SCENE1_START                  =3               --
cmd.SUB_C_SCENE2_BUY_TYPE               =4               -- 买大小
cmd.SUB_C_SCORE                         =5               -- 得分
cmd.SUB_C_SCENE3_START                  =6               --
cmd.SUB_C_GLOBAL_MESSAGE                =7
cmd.SUB_C_STOCK_OPERATE                 =8
cmd.SUB_C_ADMIN_CONTROL                 =9
cmd.SUB_C_ENDGAME                       =10
cmd.SUB_C_ANDROID_START                 =11


--下注，开始游戏
cmd.CMD_C_StartBet = {
    { t="byte", k="betIndex", },                  --总下注
}
--开始返回
cmd.CMD_S_Scene1Start = {
    { t="byte",       k="bouns_count"},                      --是否进入2级游戏  小玛丽标志
    { t="int",        k="frees_count"},                      --免费游戏次数
    { t="int",        k="all_frees_count"},                  --总的免费游戏次数
    { t="int",        k="cur_get_frees_count"},              --当前次获取免费游戏次数
    { t="score",      k="lWinScore"},                        --输赢金币
    { t="score",      k="lScore", },                         --赢分
    { t="byte",       k="bGameModes"},                        --场景状态  1：普通  2：开罐子 3：免费
    { t="byte",       k="zJLineArray",     l={cmd.MAX_LINE}}, --中奖线
    { t="byte",       k="result_icons",    l={cmd.MAX_HS, cmd.MAX_LS}},
    { t="dword",      k="dwHashID"},
    { t="dword",      k="dwCRC"},
}
--game2 敲金蛋
cmd.CMD_C_HitGoldEgg = {
    {t='int',       k='nHitPos',             },                         
}
--敲金蛋返回
cmd.Cmd_S_HitGoldEggRes = {
    {t='int',       k='nResult',             },                         --0正常成功 1表示此位置已经被点击过 2 位置不对
    {t='int',       k='nHitPos',             },                         
    {t='int',       k='nMultiply',           },                         --金币数 
    {t='int',       k='nGoldCount',          },                         -- > 0 就是金财神
    {t='byte',      k='bGameModes',          },                         --游戏状态，2:敲蛋 3：免费游戏
    {t='int',       k='freeCount',          },                         --免费次数
    {t="int",       k="all_frees_count"      },                         --总的免费游戏次数
    {t="int",       k="cur_get_frees_count"},              --当前次获取免费游戏次数
}
--开完5个罐子后推送数据
cmd.Cmd_S_GoldEggDetail = {
    {t='score',     k='lWinGold',            },                         
    {t='score',     k='lCurGold',            },                         
    {t='int',       k='nMultiply',           l = {12}},               
    {t='int',       k='nGoldWealth',         l = {12}},             
  }


return cmd