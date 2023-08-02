local module_pre = "game.yule.newcaishen.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")

local GameLogic = {}

--当前场景状态
GameLogic.SCENE_TYPE = {
    game     = 1,    --普通游戏状态         
    openEgg = 2,    --开罐子状态
    free     = 3,    --免费游戏状态
}

GameLogic.lines = {
    { { 1, 0 },{ 1, 1 } ,{ 1, 2 },{ 1, 3 },{ 1, 4 } },       --1线
    { { 0, 0 },{ 0, 1 } ,{ 0, 2 },{ 0, 3 },{ 0, 4 } },       --2线
    { { 2, 0 },{ 2, 1 } ,{ 2, 2 },{ 2, 3 },{ 2, 4 } },       --3线
    { { 0, 0 },{ 1, 1 } ,{ 2, 2 },{ 1, 3 },{ 0, 4 } },       --4线
    { { 2, 0 },{ 1, 1 } ,{ 0, 2 },{ 1, 3 },{ 2, 4 } },       --5线
    { { 0, 0 },{ 0, 1 } ,{ 1, 2 },{ 2, 3 },{ 2, 4 } },       --6线
    { { 2, 0 },{ 2, 1 } ,{ 1, 2 },{ 0, 3 },{ 0, 4 } },       --7线
    { { 1, 0 },{ 2, 1 } ,{ 0, 2 },{ 2, 3 },{ 1, 4 } },       --8线
    { { 1, 0 },{ 0, 1 } ,{ 2, 2 },{ 0, 3 },{ 1, 4 } },       --9线
    { { 0, 0 },{ 1, 1 } ,{ 0, 2 },{ 1, 3 },{ 0, 4 } },       --10线
    { { 2, 0 },{ 1, 1 } ,{ 2, 2 },{ 1, 3 },{ 2, 4 } },       --11线
    { { 1, 0 },{ 0, 1 } ,{ 1, 2 },{ 2, 3 },{ 1, 4 } },       --12线
    { { 1, 0 },{ 2, 1 } ,{ 1, 2 },{ 0, 3 },{ 1, 4 } },       --13线
    { { 0, 0 },{ 1, 1 } ,{ 1, 2 },{ 1, 3 },{ 0, 4 } },       --14线
    { { 2, 0 },{ 1, 1 } ,{ 1, 2 },{ 1, 3 },{ 2, 4 } },       --15线
    { { 1, 0 },{ 0, 1 } ,{ 0, 2 },{ 0, 3 },{ 1, 4 } },       --16线
    { { 1, 0 },{ 2, 1 } ,{ 2, 2 },{ 2, 3 },{ 1, 4 } },       --17线
    { { 0, 0 },{ 2, 1 } ,{ 2, 2 },{ 2, 3 },{ 0, 4 } },       --18线
    { { 2, 0 },{ 0, 1 } ,{ 0, 2 },{ 0, 3 },{ 2, 4 } },       --19线
    { { 0, 0 },{ 0, 1 } ,{ 2, 2 },{ 0, 3 },{ 0, 4 } },       --20线
    { { 2, 0 },{ 2, 1 } ,{ 0, 2 },{ 2, 3 },{ 2, 4 } },       --21线
    { { 1, 0 },{ 1, 1 } ,{ 0, 2 },{ 1, 3 },{ 1, 4 } },       --22线
    { { 1, 0 },{ 1, 1 } ,{ 2, 2 },{ 1, 3 },{ 1, 4 } },       --23线
    { { 0, 0 },{ 2, 1 } ,{ 0, 2 },{ 2, 3 },{ 0, 4 } },       --24线
    { { 2, 0 },{ 0, 1 } ,{ 2, 2 },{ 0, 3 },{ 2, 4 } },       --25线
    { { 2, 0 },{ 0, 1 } ,{ 1, 2 },{ 2, 3 },{ 0, 4 } },       --26线
    { { 0, 0 },{ 2, 1 } ,{ 1, 2 },{ 0, 3 },{ 2, 4 } },       --27线
    { { 0, 0 },{ 2, 1 } ,{ 1, 2 },{ 2, 3 },{ 0, 4 } },       --28线
    { { 2, 0 },{ 0, 1 } ,{ 1, 2 },{ 0, 3 },{ 2, 4 } },       --29线
    { { 2, 0 },{ 1, 1 } ,{ 0, 2 },{ 0, 3 },{ 1, 4 } },       --30线
    { { 0, 0 },{ 1, 1 } ,{ 2, 2 },{ 2, 3 },{ 1, 4 } },       --31线
    { { 0, 0 },{ 1, 1 } ,{ 0, 2 },{ 1, 3 },{ 2, 4 } },       --32线
    { { 2, 0 },{ 1, 1 } ,{ 2, 2 },{ 1, 3 },{ 0, 4 } },       --33线
    { { 1, 0 },{ 0, 1 } ,{ 2, 2 },{ 1, 3 },{ 2, 4 } },       --34线
    { { 1, 0 },{ 2, 1 } ,{ 0, 2 },{ 1, 3 },{ 0, 4 } },       --35线
    { { 2, 0 },{ 2, 1 } ,{ 0, 2 },{ 0, 3 },{ 0, 4 } },       --36线
    { { 0, 0 },{ 0, 1 } ,{ 2, 2 },{ 2, 3 },{ 2, 4 } },       --37线
    { { 0, 0 },{ 0, 1 } ,{ 1, 2 },{ 1, 3 },{ 2, 4 } },       --38线
    { { 2, 0 },{ 2, 1 } ,{ 1, 2 },{ 1, 3 },{ 0, 4 } },       --39线
    { { 0, 0 },{ 1, 1 } ,{ 1, 2 },{ 2, 3 },{ 2, 4 } },       --40线
    { { 2, 0 },{ 1, 1 } ,{ 1, 2 },{ 0, 3 },{ 0, 4 } },       --41线
    { { 2, 0 },{ 1, 1 } ,{ 0, 2 },{ 0, 3 },{ 0, 4 } },       --42线
    { { 0, 0 },{ 1, 1 } ,{ 2, 2 },{ 2, 3 },{ 2, 4 } },       --43线
    { { 1, 0 },{ 0, 1 } ,{ 0, 2 },{ 1, 3 },{ 1, 4 } },       --44线
    { { 1, 0 },{ 2, 1 } ,{ 2, 2 },{ 1, 3 },{ 1, 4 } },       --45线
    { { 1, 0 },{ 1, 1 } ,{ 0, 2 },{ 0, 3 },{ 1, 4 } },       --46线
    { { 1, 0 },{ 1, 1 } ,{ 2, 2 },{ 2, 3 },{ 1, 4 } },       --47线
    { { 2, 0 },{ 1, 1 } ,{ 0, 2 },{ 0, 3 },{ 2, 4 } },       --48线
    { { 0, 0 },{ 1, 1 } ,{ 2, 2 },{ 2, 3 },{ 0, 4 } },       --49线
    { { 0, 0 },{ 1, 1 } ,{ 1, 2 },{ 1, 3 },{ 2, 4 } },       --50线
}


--小果图片资源
GameLogic.icons = {
    -- "csd_icon_0.png",--9
    "csd_icon_1.png",--10
    "csd_icon_2.png",--J
    "csd_icon_3.png",--Q
    "csd_icon_4.png",--K
    "csd_icon_5.png",--A
    "csd_icon_6.png",--元宝
    "csd_icon_7.png",--福袋
    "csd_icon_8.png",--鞭炮
    "csd_icon_9.png",--狮子头
    "csd_icon_10.png",--财神
    "csd_icon_11.png",--普通百搭
    "csd_icon_12.png",--
    "csd_icon_13.png",--金锣
    "csd_icon_10.png",--金财神
}


GameLogic.itemType = {
    ePokerTen   =0,        -- 10
    ePokerJ     = 1 ,      -- J
    ePokerQ     = 2 ,      -- Q
    ePokerK     = 3 ,      -- K
    ePokerA     = 4 ,      -- A
    eYuanBao    = 5 ,      -- 元宝
    eHongBao    = 6 ,      -- 红包
    eBianPao    = 7 ,      -- 爆竹                           
    eLionMask   = 8 ,      -- 狮头
    eCaishen    = 9 ,      -- 财神
    CSTP_WILD= 10,      -- 发财  普通百搭   CSTP_WILD
    CSTP_FREE   = 11,      -- 
    CSTP_BONUS  = 12,      -- 金锣  【进玛丽标志】
    CSTP_WILD_FREE = 13,   --免费百搭
}

GameLogic.iconAnimName = {
    [5] = {"csd_icon_6_ske","newAnimation"},
    [6] = {"csd_icon_7_ske","newAnimation"},
    [7] = {"csd_icon_8_ske","newAnimation"},
    [8] = {"csd_icon_9_ske","newAnimation"},
    [9] = {"cs_icon_10_ske","newAnimation"},
    [10] = {"cs_wild_ske","newAnimation"},
    [11] = {"cs_gold_god_ske","change"},
    [12] = {"cs_scatter_ske","win"},
    ["boxEffect"] = {"cs_win_glow_ske","SuoDingkuang"},  --单个格子光圈
    ["bigEffect"] = {"csd_speed_ske","1"},   --一列的外框光圈
    ["wild"] = {"cs_gold_god_ske","change"},     --百搭，固定位置不动的
    ["bouns"] = {"cs_scatter_ske","get"},   --bouns 进入小玛丽标志
    ["lion_l_appear"] = {"fg_lion_l_ske","appear"},  --狮子 左 出场
    ["lion_r_appear"] = {"fg_lion_r_ske","appear"},  --狮子 右边 出场:appear 待机：idle  开出金财神：jump
    ["pot"] = {"csd_fg_ske","idle"},           --罐子  open_1:开罐子动画   open_2_start:开出金财神 open_2_end:开金财神后财神待机
    ["pot2"] = {"csd_fg_ske","open_1"},           --罐子  open_1:开罐子动画   open_2_start:开出金财神 open_2_end:开金财神后财神待机
    ["pot3"] = {"csd_fg_ske","open_2_end"},           --罐子  open_1:开罐子动画   open_2_start:开出金财神 open_2_end:开金财神后财神待机
    ["total_idle"] = {"csd_fg_total_ske","idle"},   --大财神待机
    ["total_appear"] = {"csd_fg_total_ske","appear"},   --大财神满屏金币掉落
}

local res = "game/yule/newcaishen/res/sounds/"
GameLogic.sound = {}
GameLogic.sound.openEggBG = res.."normalbg_C64kbps.mp3"   --敲蛋背景
GameLogic.sound.openEgg = res.."TreasureBowlClick.mp3"  --敲蛋
GameLogic.sound.TreasureBowGod = res.."TreasureBowlGodSymbol.mp3"  --开中金财神
GameLogic.sound.effect = res.."Level_02_C64kbps.mp3"      --光圈特效
GameLogic.sound.normal_stop = res.."normal_stop_C64kbps.mp3"   --滚完
GameLogic.sound.prewin = res.."prewin_C64kbps.mp3"   --超级滚动
GameLogic.sound.bigwin = res.."Level_09_C64kbps.mp3"   --bigwin
GameLogic.sound.bg = res.."bgm_fg.mp3"   --背景音乐


--获取线数据  
function GameLogic.getLineData(data)
    local winData = GameLogic.initNewIconData(data.result_icons)
    for i,v in ipairs(data.zJLineArray) do
        if v > 0 then
            local lineArray = GameLogic.lines[i]
            for k=1,v do
                local y = lineArray[k][1] + 1
                local x = lineArray[k][2] + 1
                winData[y][x].tag = true
            end
        end
    end
    return winData
end

--新建icons 标志数据   result_icons：服务器下发的结果数据
function GameLogic.initNewIconData(result_icons)
    --y = 行  --x = 列 = 5  
    local result_icons_tag = {}
    for y,v in ipairs(result_icons) do
        result_icons_tag[y] = {}      --行
        for x,vv in ipairs(v) do
            result_icons_tag[y][x] = {}   --列
            result_icons_tag[y][x].icon = vv
            result_icons_tag[y][x].tag = false  
            if vv == GameLogic.itemType.CSTP_BONUS then
                result_icons_tag[y][x].BOUNS = true  
            end  
            if vv == GameLogic.itemType.CSTP_WILD_FREE then
                result_icons_tag[y][x].WILD_free = true
            end      
            if vv == GameLogic.itemType.CSTP_WILD then
                result_icons_tag[y][x].WILD = true
            end      
        end
    end
    return result_icons_tag
end

--找出进入2级游戏标志的位置
function GameLogic.getGame2Data(result_icons)
    local posArray = {}
    for x=1,cmd.MAX_LS do
        for y=1, cmd.MAX_HS do 
            local idx = result_icons[y][x]
            if idx == GameLogic.itemType.CSTP_BONUS then
                table.insert(posArray,{y = y,x = x})
            end
        end
    end
    return posArray
end

------------------------模拟数据 测试用--------------------------------------
GameLogic.CMD_S_SCENE_Data = {
    lCurGold    = 17200,
    lWinGold    = 0,
    nGoldWealth = {
        [1 ] = 0,
        [2 ] = 50,
        [3 ] = 0,
        [4 ] = 50,
        [5 ] = 0,
        [6 ] = 50,
        [7 ] = 0 ,
        [8 ] = 0 ,
        [9 ] = 0 ,
        [10] = 0 ,
        [11] = 0 ,
        [12] = 0 ,
    },
    nMultiply = {
        [1 ] = 50,
        [2 ] = 200,
        [3 ] = 100,
        [4 ] = 200,
        [5 ] = 100,
        [6 ] = 200,
        [7 ] = 150,
        [8 ] = 200,
        [9 ] = 150,
        [10] = 150,
        [11] = 50,
        [12] = 100,
    }
}

GameLogic.Cmd_S_HitGoldEggRes = {
    [1] = {
        bGameModes = 2,
        nGoldCount = 0,
        nHitPos    = 0,
        nMultiply  = 50,
        nResult    = 0,
        nfreeCount = 0,
    },
    [2] = {
        bGameModes = 2,
        nGoldCount = 0,
        nHitPos    = 0,
        nMultiply  = 100,
        nResult    = 0,
        nfreeCount = 0,
    },
    [3] = {
        bGameModes = 2,
        nGoldCount = 0,
        nHitPos    = 0,
        nMultiply  = 200,
        nResult    = 0,
        nfreeCount = 0,
    },
    [4] = {
        bGameModes = 2,
        nGoldCount = 50,
        nHitPos    = 0,
        nMultiply  = 200,
        nResult    = 0,
        nfreeCount = 0,
    },
    [5] = {
        bGameModes = 3,
        nGoldCount = 50,
        nHitPos    = 0,
        nMultiply  = 200,
        nResult    = 0,
        nfreeCount = 5,
    },
}

GameLogic.gameData = {
    all_frees_count     = 0,
    bouns_count         = 1,
    cur_get_frees_count = 0,
    dwCRC               = 4294967209,
    dwHashID            = 77819474,
    frees_count         = 0,
    bGameModes           = 2,
    lScore              = 1.5000000380685e+15,
    lWinScore           = 60,
    result_icons = {
        [1] = {
            [1] = 12,
            [2] = 1,
            [3] = 12,
            [4] = 7,
            [5] = 6,
        },
        [2] = {
            [1] = 1,
            [2] = 2,
            [3] = 1,
            [4] = 1,
            [5] = 12,
        },
        [3] = {
            [1] = 10,
            [2] = 10,
            [3] = 10,
            [4] = 10,
            [5] = 0,
        },
    },
    zJLineArray = {
        [1] = 0,
        [2] = 0,
        [3] = 4,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 3,
        [10] = 0,
        [11] = 0,
        [12] = 3,
        [13] = 0,
        [14] = 0,
        [15] = 0,
        [16] = 0,
        [17] = 0,
        [18] = 0,
        [19] = 0,
        [20] = 0,
        [21] = 0,
        [22] = 0,
        [23] = 0,
        [24] = 0,
        [25] = 0,
        [26] = 0,
        [27] = 0,
        [28] = 0,
        [29] = 0,
        [30] = 0,
        [31] = 0,
        [32] = 0,
        [33] = 0,
        [34] = 4,
        [35] = 0,
        [36] = 0,
        [37] = 0,
        [38] = 0,
        [39] = 0,
        [40] = 0,
        [41] = 0,
        [42] = 0,
        [43] = 0,
        [44] = 0,
        [45] = 0,
        [46] = 0,
        [47] = 0,
        [48] = 0,
        [49] = 0,
        [50] = 0,
    }
}

GameLogic.onEventGameScene_2 = {
    all_frees_count     = 0,
    bGameModes          = 2,
    bet_score           = 50,
    bonus_step          = 0,
    bouns_count         = 0,
    cur_get_frees_count = 0,
    dwCRC               = 4294967226,
    dwHashID            = 127160638,
    frees_count         = 0,
    lBounsWinScore = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        },
    nFreeTotalAwardGold = 2450,
    nGoldWealth = {
        [1] = 1,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 1,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
        },
    nMultiply = {
        [1] = 350,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 1050,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 1050,
        },
    result_icons = {
        [1] = {
            [1] = 12,
            [2] = 4,
            [3] = 2,
            [4] = 2,
            [5] = 1,
        },
        [2] = {
            [1] = 3,
            [2] = 2,
            [3] = 2,
            [4] = 1,
            [5] = 12,
        },
        [3] = {
            [1] = 12,
            [2] = 1,
            [3] = 4,
            [4] = 0,
            [5] = 1,
        },
    },
    win_score = {
        [1] = 9808981,
    },
    zJLineArray = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
        [13] = 0,
        [14] = 0,
        [15] = 0,
        [16] = 0,
        [17] = 0,
        [18] = 0,
        [19] = 0,
        [20] = 0,
        [21] = 0,
        [22] = 0,
        [23] = 0,
        [24] = 0,
        [25] = 0,
        [26] = 0,
        [27] = 0,
        [28] = 0,
        [29] = 0,
        [30] = 0,
        [31] = 0,
        [32] = 0,
        [33] = 0,
        [34] = 0,
        [35] = 0,
        [36] = 0,
        [37] = 0,
        [38] = 0,
        [39] = 0,
        [40] = 0,
        [41] = 0,
        [42] = 0,
        [43] = 0,
        [44] = 0,
        [45] = 0,
        [46] = 0,
        [47] = 0,
        [48] = 0,
        [49] = 0,
        [50] = 0,
    },
}

GameLogic.onEventGameScene_3 = {
    all_frees_count     = 8,
    bGameModes          = 3,
    bet_score           = 50,
    bonus_step          = 0,
    bouns_count         = 0,
    cur_get_frees_count = 5,
    dwCRC               = 4294967194,
    dwHashID            = 1261364237,
    frees_count         = 5,
    lBounsWinScore = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
    },
    nFreeTotalAwardGold = 1150000,
    nGoldWealth = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
    },
    nMultiply = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
    },
    result_icons = {
        [1] = {
            [1] = 12,
            [2] = 2,
            [3] = 0,
            [4] = 3,
            [5] = 12,
        },
        [2] = {
            [1] = 4,
            [2] = 5,
            [3] = 12,
            [4] = 5,
            [5] = 2,
        },
        [3] = {
            [1] = 4,
            [2] = 1,
            [3] = 0,
            [4] = 3,
            [5] = 7,
        },
    },
    win_score = {
        [1] = 9809268,
    },
    zJLineArray = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
        [13] = 0,
        [14] = 0,
        [15] = 0,
        [16] = 0,
        [17] = 0,
        [18] = 0,
        [19] = 0,
        [20] = 0,
        [21] = 0,
        [22] = 0,
        [23] = 0,
        [24] = 0,
        [25] = 0,
        [26] = 0,
        [27] = 0,
        [28] = 0,
        [29] = 0,
        [30] = 0,
        [31] = 0,
        [32] = 0,
        [33] = 0,
        [34] = 0,
        [35] = 0,
        [36] = 0,
        [37] = 0,
        [38] = 0,
        [39] = 0,
        [40] = 0,
        [41] = 0,
        [42] = 0,
        [43] = 0,
        [44] = 0,
        [45] = 0,
        [46] = 0,
        [47] = 0,
        [48] = 0,
        [49] = 0,
        [50] = 0,
    },
}
return GameLogic
