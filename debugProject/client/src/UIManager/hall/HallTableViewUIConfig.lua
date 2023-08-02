local HallTableViewUIConfig = {}

HallTableViewUIConfig.AnimationConfig = {
    -- --背景左侧
    ["SpineLeft"]            = {PathJson = "spine/datingchangjing_zuo_cao.json",PathAtlas  = "spine/datingchangjing_zuo_cao.atlas", AnimationName = "daiji",},
    --背景上方
    ["SpineTop"]             = {PathJson = "spine/datingchangjing_shang.json",  PathAtlas  = "spine/datingchangjing_shang.atlas",   AnimationName = "daiji",},
    --背景右侧
    ["SpineRight"]           = {PathJson = "spine/datingchangjing_you_shu.json",PathAtlas  = "spine/datingchangjing_you_shu.atlas", AnimationName = "daiji",},    
    --礼包中心
    ["NodeGift"]             = {PathJson = "spine/lingbaotubiao.json",          PathAtlas  = "spine/lingbaotubiao.atlas",           AnimationName = "daiji",        PathCSB  = "Lobby/Entry/NodeGift.csb",          ActionName = "",},
    --破产补助
    ["NodeBankrupt"]         = {PathCSB  = "Lobby/Entry/NodeBankrupt.csb",      ActionName = "",},    
    --每日签到
    ["NodeDaily"]            = {PathJson = "spine/lianxudengru.json",           PathAtlas  = "spine/lianxudengru.atlas",            AnimationName = "animation",},
    --任务
    ["NodeTask"]             = {PathJson = "spine/renwu.json",                  PathAtlas  = "spine/renwu.atlas",                   AnimationName = "animation",},
    --绑定手机
    ["NodeBinding"]          = {PathJson = "spine/shoujizhuce.json",            PathAtlas  = "spine/shoujizhuce.atlas",             AnimationName = "animation",    PathCSB  = "Lobby/Entry/NodeBinding.csb",       ActionName = "",},
    --每日分享
    ["NodeShare"]            = {PathJson = "spine/fenxiang.json",               PathAtlas  = "spine/fenxiang.atlas",                AnimationName = "animation",},    
    --塔罗牌
    ["NodeTarot"]            = {PathJson = "spine/taluopai.json",               PathAtlas  = "spine/taluopai.atlas",                AnimationName = "animation",},
    --邀请码
    ["NodeGiftCode"]         = {PathJson = "spine/yaoqingma.json",              PathAtlas  = "spine/yaoqingma.atlas",               AnimationName = "animation",},
    --限时礼包
    ["NodeGiftCodeShop"]     = {PathJson = "spine/xianshilibao.json",           PathAtlas  = "spine/xianshilibao.atlas",            AnimationName = "animation",},           
    --VIP
    ["NodeVIP"]              = {PathJson = "spine/VIP.json",                    PathAtlas  = "spine/VIP.atlas",                     AnimationName = "daiji",},        
    --分享转盘
    ["NodeShareTurn"]        = {PathJson = "spine/dating_yaoqing.json",         PathAtlas  = "spine/dating_yaoqing.atlas",          AnimationName = "daiji",},
    ["NodeTruntable"]        = {PathJson = "spine/zhuanpang.json",              PathAtlas  = "spine/zhuanpang.atlas",               AnimationName = "daiji",}, 
    --提现
    ["NodeWithdraw"]         = {PathJson = "spine/tixianrukou.json",            PathAtlas  = "spine/tixianrukou.atlas",             AnimationName = "daiji",},    
    --商店
    ["NodeShop"]             = {PathCSB  = "Lobby/Entry/NodeShop.csb",          ActionName = "",},    
}  

--玩法标题配置
local TitleConfig = {
    [407] = "client/res/Lobby/GUI/RoomList/title_LKPY.png",
    [502] = "client/res/Lobby/GUI/RoomList/title_97QH.png",
    [516] = "client/res/Lobby/GUI/RoomList/title_SHZ.png",
    [520] = "client/res/Lobby/GUI/RoomList/title_DNTG.png",
    [525] = "client/res/Lobby/GUI/RoomList/title_JXLW.png",
    [527] = "client/res/Lobby/GUI/RoomList/title_BLCS.png",
    [528] = "client/res/Lobby/GUI/RoomList/title_Egito.png",
    [704] = "client/res/Lobby/GUI/RoomList/title_TMFK.png",
    [803] = "client/res/Lobby/GUI/RoomList/title_Truco.png",
    [901] = "client/res/Lobby/GUI/RoomList/title_Plinko.png",
    [532] = "client/res/Lobby/GUI/RoomList/title_BXNW.png",
    [529] = "client/res/Lobby/GUI/RoomList/title_CSD.png",
    [531] = "client/res/Lobby/GUI/RoomList/title_JNH.png",
}

--游戏是否为API游戏或者本地游戏
local GameType = {
    NULL        = nil,                      --特殊，无归类
    SelectRoom  = "SelectRoom",             --场次
    OG          = "OfficialGame",           --自研游戏
    EG          = "EasyGame",               --EG厂商
    PG          = "PocketGame",             --PG厂商
}


--大厅滑动列表配置
HallTableViewUIConfig.gameIconConfig={
    -- {{ID=nil,Name="NodePGEntry",size=cc.size(410,800),desc="PG厂商入口",Type=GameType.NULL,},},
    {{ID=nil,Name="GameHallActivity",size=cc.size(780,320),desc="活动图",Type=GameType.NULL,},{{ID=12500,Name="Game12500",desc="FortuneTiger",Type=GameType.EG,},{ID=12400,Name="Game12400",desc="FortuneOx",Type=GameType.EG,}}},
    {{ID=704,Name="GameTMFK",desc="甜蜜富矿",Type=GameType.OG,},{ID=901,Name="GamePlinko",desc="Pinko",Type=GameType.OG,}},
    {{ID=525,Name="GameJXLW",desc="九线拉王",Type=GameType.OG,},{ID=532,Name="GameBXNW",desc="冰雪女王",Type=GameType.OG,}},
    {{ID=529,Name="GameCSD",desc="财神到",Type=GameType.OG,},{ID=531,Name="GameJNH",desc="嘉年华",Type=GameType.OG,}},
    {{ID=11000,Name="Game11000",desc="龙孵化",Type=GameType.EG,},{ID=527,Name="GameBLCS",desc="秘鲁传说",Type=GameType.OG,}},
    {{ID=12100,Name="Game12100",desc="雷神",Type=GameType.EG,},{ID=528,Name="GameEgito",desc="埃及拉霸",Type=GameType.OG,}},
    {{ID=6100,Name="Game6100",desc="水果机",Type=GameType.EG,},{ID=502,Name="Game97QH",desc="97拳皇",Type=GameType.OG,}},
    {{ID=4400,Name="Game4400",desc="富贵熊猫",Type=GameType.EG,},{ID=516,Name="GameSHZ",desc="水浒传",Type=GameType.OG,}},
    {{ID=5900,Name="Game5900",desc="骑士",Type=GameType.EG,},{ID=703,Name="GameCrash",desc="Crash",Type=GameType.OG,}},
    {{ID=6400,Name="Game6400",desc="池塘",Type=GameType.EG,},{ID=903,Name="GameLPD",desc="轮盘赌",Type=GameType.OG,}},
    {{ID=8600,Name="Game8600",desc="花木兰",Type=GameType.EG,},{ID=520,Name="GameDNTG",desc="大闹天宫",Type=GameType.OG,gameType=GameType.SelectRoom}},
    {{ID=4700,Name="Game4700",desc="白狮",Type=GameType.EG,},{ID=602,Name="GameBicho",desc="动物世界",Type=GameType.OG,}},
    {{ID=4600,Name="Game4600",desc="咆哮荒野",Type=GameType.EG,},{ID=122,Name="GameBJL",desc="百家乐",Type=GameType.OG,}},
    {{ID=7700,Name="Game7700",desc="开心农场",Type=GameType.EG,},{ID=407,Name="GameLKPY",desc="李逵劈鱼",Type=GameType.OG,gameType=GameType.SelectRoom}},
    {{ID=6300,Name="Game6300",desc="公主",Type=GameType.EG,},{ID=702,Name="GameDouble",desc="Double",Type=GameType.OG,}},
    {{ID=5100,Name="Game5100",desc="魔术师",Type=GameType.EG,},{ID=27100,Name="Game27100",desc="足球",Type=GameType.EG,}},
    {{ID=12000,Name="Game12000",desc="玛雅消除",Type=GameType.EG,},{ID=27200,Name="Game27200",desc="Dice",Type=GameType.EG,}},
    {{ID=4300,Name="Game4300",desc="多福多财",Type=GameType.EG,},{ID=23600,Name="Game23600",desc="扫雷",Type=GameType.EG,}},
    {{ID=4200,Name="Game4200",desc="埃及秘宝",Type=GameType.EG,},{ID=27400,Name="Game27400",desc="桌球",Type=GameType.EG,}},
    {{ID=6500,Name="Game6500",desc="城堡",Type=GameType.EG,},{ID=27700,Name="Game27700",desc="Keno",Type=GameType.EG,}},
    {{ID=7400,Name="Game7400",desc="丛林女王",Type=GameType.EG,},{ID=28000,Name="Game28000",desc="红黑扑克",Type=GameType.EG,}},
    {{ID=5500,Name="Game5500",desc="大蓝鲸",Type=GameType.EG,},{ID=28700,Name="Game28700",desc="28700连局",Type=GameType.EG,}},
    {{ID=5600,Name="Game5600",desc="公路之王",Type=GameType.EG,},{ID=28600,Name="Game28600",desc="MagicWheel",Type=GameType.EG,}},
    {{ID=7600,Name="Game7600",desc="齐天大圣",Type=GameType.EG,},{ID=28200,Name="Game28200",desc="WheelOfSky",Type=GameType.EG,}},
    {{ID=4800,Name="Game4800",desc="忍者",Type=GameType.EG,},{ID=28300,Name="Game28300",desc="Fortunewheel",Type=GameType.EG,}},
    {{ID=5800,Name="Game5800",desc="海盗",Type=GameType.EG,},{ID=27800,Name="Game27800",desc="Thimbles",Type=GameType.EG,}},
    {{ID=8900,Name="Game8900",desc="三国",Type=GameType.EG,},{ID=28400,Name="Game28400",desc="DadosDaSorte",Type=GameType.EG,}},
    {{ID=7100,Name="Game7100",desc="玛雅帝国",Type=GameType.EG,},{ID=27900,Name="Game27900",desc="沙滩足球",Type=GameType.EG,}},
    {{ID=8100,Name="Game8100",desc="黑手党",Type=GameType.EG,},{ID=27500,Name="Game27500",desc="俄罗斯轮盘",Type=GameType.EG,}},
    {{ID=6600,Name="Game6600",desc="猫咪",Type=GameType.EG,},{ID=27600,Name="GameTruco",desc="Truco",Type=GameType.EG,}},
    {{ID=7000,Name="Game7000",desc="EasterIsland",Type=GameType.EG,},{ID=4100,Name="Game4100",desc="水牛",Type=GameType.EG,}},
    {{ID=7800,Name="Game7800",desc="怪物",Type=GameType.EG,},{ID=5400,Name="Game5400",desc="海豚之夜",Type=GameType.EG,}},
    {{ID=7900,Name="Game7900",desc="沙滩甜心",Type=GameType.EG,},{ID=8700,Name="Game8700",desc="森林舞会",Type=GameType.EG,}},
    {{ID=4500,Name="Game4500",desc="五龙争霸",Type=GameType.EG,},{ID=5000,Name="Game5000",desc="圣诞",Type=GameType.EG,}},
    {{ID=9100,Name="Game9100",desc="风财聚宝",Type=GameType.EG,},{ID=5200,Name="Game5200",desc="挖矿",Type=GameType.EG,}},
    {{ID=5300,Name="Game5300",desc="小蜜蜂",Type=GameType.EG,},{ID=6000,Name="Game6000",desc="精灵女王",Type=GameType.EG,}},
    {{ID=6200,Name="Game6200",desc="女巫",Type=GameType.EG,},{ID=6700,Name="Game6700",desc="斯巴达",Type=GameType.EG,}},
    {{ID=6800,Name="Game6800",desc="性感小魔女",Type=GameType.EG,},{ID=6900,Name="Game6900",desc="火山",Type=GameType.EG,}},
    {{ID=7300,Name="Game7300",desc="迪斯科",Type=GameType.EG,},{ID=520,Name="GameDNTG",desc="大闹天宫",Type=GameType.OG,gameType=GameType.SelectRoom}}
}

HallTableViewUIConfig.gameIconConfigHOT={
    -- {{ID=nil,Name="NodePGEntry",size=cc.size(410,800),desc="PG厂商入口",Type=GameType.NULL,},},
    {{ID=nil,Name="GameHallActivity",size=cc.size(780,320),desc="活动图",Type=GameType.NULL,},{{ID=12500,Name="Game12500",desc="FortuneTiger",Type=GameType.EG,},{ID=12400,Name="Game12400",desc="FortuneOx",Type=GameType.EG,}}},
    {{ID=704,Name="GameTMFK",desc="甜蜜富矿",Type=GameType.OG,},{ID=901,Name="GamePlinko",desc="Pinko",Type=GameType.OG,}},
    {{ID=527,Name="GameBLCS",desc="秘鲁传说",Type=GameType.OG,},{ID=529,Name="GameCSD",desc="财神到",Type=GameType.OG,}},
    {{ID=532,Name="GameBXNW",desc="冰雪女王",Type=GameType.OG,},{ID=525,Name="GameJXLW",desc="九线拉王",Type=GameType.OG,}},
    {{ID=903,Name="GameLPD",desc="轮盘赌",Type=GameType.OG,},{ID=703,Name="GameCrash",desc="Crash",Type=GameType.OG,}},
    {{ID=23600,Name="Game23600",desc="扫雷",Type=GameType.EG,},{ID=520,Name="GameDNTG",desc="大闹天宫",Type=GameType.OG,gameType=GameType.SelectRoom}},
    {{ID=12100,Name="Game12100",desc="雷神",Type=GameType.EG,},{ID=11000,Name="Game11000",desc="龙孵化",Type=GameType.EG,}},
    {{ID=27100,Name="Game27100",desc="足球",Type=GameType.EG,},{ID=27400,Name="Game27400",desc="桌球",Type=GameType.EG,}}
}

HallTableViewUIConfig.gameIconConfigSLOT={
    -- {{ID=nil,Name="NodePGEntry",size=cc.size(410,800),desc="PG厂商入口",Type=GameType.NULL,},},
    {{ID=12500,Name="Game12500",desc="FortuneTiger",Type=GameType.EG,},{ID=12400,Name="Game12400",desc="FortuneOx",Type=GameType.EG,}},
    {{ID=704,Name="GameTMFK",desc="甜蜜富矿",Type=GameType.OG,},{ID=527,Name="GameBLCS",desc="秘鲁传说",Type=GameType.OG,}},
    {{ID=525,Name="GameJXLW",desc="九线拉王",Type=GameType.OG,},{ID=532,Name="GameBXNW",desc="冰雪女王",Type=GameType.OG,}},
    {{ID=529,Name="GameCSD",desc="财神到",Type=GameType.OG,},{ID=531,Name="GameJNH",desc="嘉年华",Type=GameType.OG,}},
    {{ID=11000,Name="Game11000",desc="龙孵化",Type=GameType.EG,},{ID=528,Name="GameEgito",desc="埃及拉霸",Type=GameType.OG,}},
    {{ID=12100,Name="Game12100",desc="雷神",Type=GameType.EG,},{ID=502,Name="Game97QH",desc="97拳皇",Type=GameType.OG,}},
    {{ID=6100,Name="Game6100",desc="水果机",Type=GameType.EG,},{ID=516,Name="GameSHZ",desc="水浒传",Type=GameType.OG,}},
    {{ID=4400,Name="Game4400",desc="富贵熊猫",Type=GameType.EG,},{ID=5900,Name="Game5900",desc="骑士",Type=GameType.EG,}},
    {{ID=6400,Name="Game6400",desc="池塘",Type=GameType.EG,},{ID=8600,Name="Game8600",desc="花木兰",Type=GameType.EG,}},
    {{ID=4700,Name="Game4700",desc="白狮",Type=GameType.EG,},{ID=4600,Name="Game4600",desc="咆哮荒野",Type=GameType.EG,}},
    {{ID=7700,Name="Game7700",desc="开心农场",Type=GameType.EG,},{ID=6300,Name="Game6300",desc="公主",Type=GameType.EG,}},
    {{ID=5100,Name="Game5100",desc="魔术师",Type=GameType.EG,},{ID=12000,Name="Game12000",desc="玛雅消除",Type=GameType.EG,}},
    {{ID=4300,Name="Game4300",desc="多福多财",Type=GameType.EG,},{ID=4200,Name="Game4200",desc="埃及秘宝",Type=GameType.EG,}},
    {{ID=6500,Name="Game6500",desc="城堡",Type=GameType.EG,},{ID=7400,Name="Game7400",desc="丛林女王",Type=GameType.EG,}},
    {{ID=5500,Name="Game5500",desc="大蓝鲸",Type=GameType.EG,},{ID=5600,Name="Game5600",desc="公路之王",Type=GameType.EG,}},
    {{ID=7600,Name="Game7600",desc="齐天大圣",Type=GameType.EG,},{ID=4800,Name="Game4800",desc="忍者",Type=GameType.EG,}},
    {{ID=5800,Name="Game5800",desc="海盗",Type=GameType.EG,},{ID=8900,Name="Game8900",desc="三国",Type=GameType.EG,}},
    {{ID=7100,Name="Game7100",desc="玛雅帝国",Type=GameType.EG,},{ID=8100,Name="Game8100",desc="黑手党",Type=GameType.EG,}},
    {{ID=6600,Name="Game6600",desc="猫咪",Type=GameType.EG,},{ID=4100,Name="Game4100",desc="水牛",Type=GameType.EG,}},
    {{ID=7000,Name="Game7000",desc="EasterIsland",Type=GameType.EG,},{ID=5400,Name="Game5400",desc="海豚之夜",Type=GameType.EG,}},
    {{ID=7800,Name="Game7800",desc="怪物",Type=GameType.EG,},{ID=8700,Name="Game8700",desc="森林舞会",Type=GameType.EG,}},
    {{ID=7900,Name="Game7900",desc="沙滩甜心",Type=GameType.EG,},{ID=5000,Name="Game5000",desc="圣诞",Type=GameType.EG,}},
    {{ID=4500,Name="Game4500",desc="五龙争霸",Type=GameType.EG,},{ID=5200,Name="Game5200",desc="挖矿",Type=GameType.EG,}},
    {{ID=9100,Name="Game9100",desc="风财聚宝",Type=GameType.EG,},{ID=6000,Name="Game6000",desc="精灵女王",Type=GameType.EG,}},
    {{ID=5300,Name="Game5300",desc="小蜜蜂",Type=GameType.EG,},{ID=6700,Name="Game6700",desc="斯巴达",Type=GameType.EG,}},
    {{ID=6200,Name="Game6200",desc="女巫",Type=GameType.EG,},{ID=6900,Name="Game6900",desc="火山",Type=GameType.EG,}},
    {{ID=6800,Name="Game6800",desc="性感小魔女",Type=GameType.EG,},{ID=7300,Name="Game7300",desc="迪斯科",Type=GameType.EG,}},
    {{ID=9400,Name="Game9400",desc="丧尸国度",Type=GameType.EG}}
}

HallTableViewUIConfig.gameIconConfigLAZER={
    -- {{ID=nil,Name="NodePGEntry",size=cc.size(410,800),desc="PG厂商入口",Type=GameType.NULL,},},
    {{ID=901,Name="GamePlinko",desc="Pinko",Type=GameType.OG,},{ID=703,Name="GameCrash",desc="Crash",Type=GameType.OG,}},
    {{ID=903,Name="GameLPD",desc="轮盘赌",Type=GameType.OG,},{ID=520,Name="GameDNTG",desc="大闹天宫",Type=GameType.OG,gameType=GameType.SelectRoom}},
    {{ID=602,Name="GameBicho",desc="动物世界",Type=GameType.OG,},{ID=122,Name="GameBJL",desc="百家乐",Type=GameType.OG,}},
    {{ID=407,Name="GameLKPY",desc="李逵劈鱼",Type=GameType.OG,gameType=GameType.SelectRoom},{ID=702,Name="GameDouble",desc="Double",Type=GameType.OG,}},
    {{ID=27100,Name="Game27100",desc="足球",Type=GameType.EG,},{ID=27200,Name="Game27200",desc="Dice",Type=GameType.EG,}},
    {{ID=23600,Name="Game23600",desc="扫雷",Type=GameType.EG,},{ID=27400,Name="Game27400",desc="桌球",Type=GameType.EG,}},
    {{ID=27700,Name="Game27700",desc="Keno",Type=GameType.EG,},{ID=28000,Name="Game28000",desc="红黑扑克",Type=GameType.EG,}},
    {{ID=28700,Name="Game28700",desc="28700连局",Type=GameType.EG,},{ID=28600,Name="Game28600",desc="MagicWheel",Type=GameType.EG,}},
    {{ID=28200,Name="Game28200",desc="WheelOfSky",Type=GameType.EG,},{ID=28300,Name="Game28300",desc="Fortunewheel",Type=GameType.EG,}},
    {{ID=27800,Name="Game27800",desc="Thimbles",Type=GameType.EG,},{ID=28400,Name="Game28400",desc="DadosDaSorte",Type=GameType.EG,}},
    {{ID=27900,Name="Game27900",desc="沙滩足球",Type=GameType.EG,},{ID=27500,Name="Game27500",desc="俄罗斯轮盘",Type=GameType.EG,}},
    {{ID=27600,Name="GameTruco",desc="Truco",Type=GameType.EG,}}
}

HallTableViewUIConfig.GameType = GameType
HallTableViewUIConfig.TitleConfig = TitleConfig
return HallTableViewUIConfig