local HallTableViewUIConfig = {}

HallTableViewUIConfig.AnimationConfig = {
    -- --背景左侧
    ["SpineLeft"]            = {PathJson = "spine/datingchangjing_zuo_cao.json",PathAtlas  = "spine/datingchangjing_zuo_cao.atlas", AnimationName = "daiji",},
    --背景上方
    ["SpineTop"]             = {PathJson = "spine/datingchangjing_shang.json",  PathAtlas  = "spine/datingchangjing_shang.atlas",   AnimationName = "daiji",},
    --背景右侧
    ["SpineRight"]           = {PathJson = "spine/datingchangjing_you_shu.json",PathAtlas  = "spine/datingchangjing_you_shu.atlas", AnimationName = "daiji",},
    --美女形象
    --["NodeAvatar"]           = {PathJson = "spine/juese.json",                  PathAtlas  = "spine/juese.atlas",                   AnimationName = "daiji",},

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
    --分享转盘
    -- ["NodeShareTurn"]        = {PathJson = "spine/dating_yaoqing.json",         PathAtlas  = "spine/dating_yaoqing.atlas",          AnimationName = "daiji",},
    --VIP
    ["NodeVIP"]              = {PathJson = "spine/VIP.json",                    PathAtlas  = "spine/VIP.atlas",                     AnimationName = "daiji",},    
    --转盘
    -- ["NodeTruntable"]        = {PathJson = "spine/zhuanpang.json",         PathAtlas  = "spine/zhuanpang.atlas",          AnimationName = "daiji",},
    --分享转盘
    ["NodeShareTurn"]        = {PathJson = "spine/dating_yaoqing.json",         PathAtlas  = "spine/dating_yaoqing.atlas",          AnimationName = "daiji",},
    ["NodeTruntable"]        = {PathJson = "spine/zhuanpang.json",              PathAtlas  = "spine/zhuanpang.atlas",               AnimationName = "daiji",},    
    --商店
    ["NodeShop"]             = {PathCSB  = "Lobby/Entry/NodeShop.csb",          ActionName = "",},
    --Slots类入口
    --["TypeSlots"]            = {PathJson = "spine/slots.json",                  PathAtlas  = "spine/slots.atlas",                   AnimationName = "animation",},
    --捕鱼场，百人场入口
    --["TypeEspecial"]         = {PathJson = "spine/especial.json",               PathAtlas  = "spine/especial.atlas",                AnimationName = "animation",},
    --甜蜜富矿
    --["HallFrutas"]           = {PathJson = "spine/bonanza.json",                PathAtlas  = "spine/bonanza.atlas",                 AnimationName = "daiji",},
    --Pinko
    --["HallPinko"]            = {PathJson = "spine/pinko.json",                  PathAtlas  = "spine/pinko.atlas",                 AnimationName = "daiji",},
    --Crash
    --["HallCrash"]            = {PathJson = "spine/crash.json",                  PathAtlas  = "spine/crash.atlas",                   AnimationName = "daiji",},    

    --俄罗斯轮盘
    --["HallLPD"]              = {PathJson = "spine/lunpanrukou.json",            PathAtlas  = "spine/lunpanrukou.atlas",             AnimationName = "animation",},
    --九线拉王
    --["HallJXLW"]             = {PathJson = "spine/777.json",                    PathAtlas  = "spine/youxirukou.atlas",              AnimationName = "daiji",},
    --冰雪女王
    --["HallBXNW"]             = {PathJson = "spine/bingxue.json",                PathAtlas  = "spine/youxirukou.atlas",              AnimationName = "daiji",},        
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
local GAME_TYPE = {
    SLOCAL = "OfficialGame",
    API = "EasyGame",
    SELECTROOM = "SELECTROOM",              --游戏是否还需要有选场次
    NULL = nil
}
--大厅滑动列表配置
HallTableViewUIConfig.gameIconConfig = {
    [1] = {                         --第一项
        {
            ID = nil,
            Name = nil,
            size = cc.size(780,320),
            desc = "活动图",
            imagePath = "",
            Type = GAME_TYPE.NULL,
            spineFileName = nil
        },               
        {
            {
                ID = 901,
                Name = "GamePlinko", 
                size = cc.size(390,320),
                desc = "Pinko",
                imagePath = "Lobby/Entry/GamePlinko.csb",
                Type = GAME_TYPE.SLOCAL,
                spineFileName = nil,
                -- gameType = GAME_TYPE.SELECTROOM
            },           
            {
                ID = 23600,
                Name = "Game23600", 
                size = cc.size(390,320),
                desc = "扫雷",
                imagePath = "Lobby/Entry/Game23600.csb",
                Type = GAME_TYPE.API,
                Status = true,
                spineFileName = nil
            }            
        }
     },     
    [2] = {         
        {                   --甜蜜富矿
            ID = 704,
            Name = "GameTMFK",
            size = cc.size(390,320),
            desc = "甜蜜富矿",
            imagePath = "Lobby/Entry/GameTMFK.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },
        {                   --Crasg
            ID = 703,
            Name = "GameCrash",
            size = cc.size(390,320),
            desc = "Crash",
            imagePath = "Lobby/Entry/GameCrash.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil
        }
    },
    
    [3] = {      
        {                   --九线拉王
            ID = 525,
            Name = "GameJXLW",
            size = cc.size(390,320),
            desc = "九线拉王",
            imagePath = "Lobby/Entry/GameJXLW.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        }, 
        {                   --足球
            ID = 27100,
            Name = "Game27100",
            size = cc.size(390,320),
            desc = "足球",
            imagePath = "Lobby/Entry/Game27100.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
            -- gameType = GAME_TYPE.SELECTROOM
        }           
        
    },
    [4] = {                      
        {                   --雪女
            ID = 532,
            Name = "GameBXNW",
            size = cc.size(390,320),
            desc = "冰雪女王",
            imagePath = "Lobby/Entry/GameBXNW.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },
        {                   --Dice
            ID = 27300,
            Name = "Game27300",
            size = cc.size(390,320),
            desc = "Dice",
            imagePath = "Lobby/Entry/Game27300.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }                        
    },                
    [5] = {         
        {                   --嘉年华
            ID = 531,
            Name = "GameJNH",
            size = cc.size(390,320),
            desc = "嘉年华",
            imagePath = "Lobby/Entry/GameJNH.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },
        {                   --桌球
            ID = 27400,
            Name = "Game27400",
            size = cc.size(390,320),
            desc = "桌球",
            imagePath = "Lobby/Entry/Game27400.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }
    },          
    [6] = {   
        {                   --财神到
            ID = 529,
            Name = "GameCSD",
            size = cc.size(390,320),
            desc = "财神到",
            imagePath = "Lobby/Entry/GameCSD.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },
        {                   --转盘
            ID = 27200,
            Name = "Game27200",
            size = cc.size(390,320),
            desc = "Dice",
            imagePath = "Lobby/Entry/Game27200.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }  
        
    },
    [7] = {
        {                   --秘鲁传说
            ID = 527,
            Name = "GameBLCS",
            size = cc.size(390,320),
            desc = "秘鲁传说",
            imagePath = "Lobby/Entry/GameBLCS.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },             
        {                   --轮盘赌
            ID = 903,
            Name = "GameLPD",
            size = cc.size(390,320),
            desc = "LPD",
            imagePath = "Lobby/Entry/GameLPD.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil
        }
    },            
    [8] = {                      

        {                   --埃及拉霸
            ID = 528,
            Name = "GameEgito",
            size = cc.size(390,320),
            desc = "埃及拉霸",
            imagePath = "Lobby/Entry/GameEgito.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        }, 
        {                   --大闹天宫
            ID = 520,
            Name = "GameDNTG",
            size = cc.size(390,320),
            desc = "大闹天宫",
            imagePath = "Lobby/Entry/GameDNTG.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            gameType = GAME_TYPE.SELECTROOM
        }  
    },
    [9] = {       
        {                   --97拳皇
            ID = 502,
            Name = "Game97QH",
            size = cc.size(390,320),
            desc = "97拳皇",
            imagePath = "Lobby/Entry/Game97QH.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },
        {                   --JOGO DO BICHO
            ID = 602,
            Name = "GameBicho",
            size = cc.size(390,320),
            desc = "Bicho",
            imagePath = "Lobby/Entry/GameBicho.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil
        }           
    },        
    [10] = {  
        {                   --水浒传
            ID = 516,
            Name = "GameSHZ",
            size = cc.size(390,320),
            desc = "水浒传",
            imagePath = "Lobby/Entry/GameSHZ.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            -- gameType = GAME_TYPE.SELECTROOM
        },            
        {                   --Truco
            ID = 803,
            Name = "GameTruco",
            size = cc.size(390,320),
            desc = "Truco",
            imagePath = "Lobby/Entry/GameTruco.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            gameType = GAME_TYPE.SELECTROOM
        }
    },
    [11] = {                          
        {                   --水果机
            ID = 6100,
            Name = "Game6100",
            size = cc.size(390,320),
            desc = "水果机",
            imagePath = "Lobby/Entry/Game6100.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },                           
        {                   --百家乐
            ID = 122,
            Name = "GameBJL",
            size = cc.size(390,320),
            desc = "GameBJL",
            imagePath = "Lobby/Entry/GameBJL.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil
        }
    },
    [12] = {   
        {                   --富贵熊猫
            ID = 4400,
            Name = "Game4400",
            size = cc.size(390,320),
            desc = "富贵熊猫",
            imagePath = "Lobby/Entry/Game4400.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },    
        {                   --李逵劈鱼
            ID = 407,
            Name = "GameLKPY",
            size = cc.size(390,320),
            desc = "李逵劈鱼",
            imagePath = "Lobby/Entry/GameLKPY.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil,
            gameType = GAME_TYPE.SELECTROOM
        }
    },
    [13] = {                        
        {                   --骑士
            ID = 5900,
            Name = "Game5900",
            size = cc.size(390,320),
            desc = "骑士",
            imagePath = "Lobby/Entry/Game5900.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },                   
        {                   --Double
            ID = 702,
            Name = "GameDouble",
            size = cc.size(390,320),
            desc = "Double",
            imagePath = "Lobby/Entry/GameDouble.csb",
            Type = GAME_TYPE.SLOCAL,
            spineFileName = nil
        }
    },
    [14] = {                      
        {                   --池塘
            ID = 6400,
            Name = "Game6400",
            size = cc.size(390,320),
            desc = "池塘",
            imagePath = "Lobby/Entry/Game6400.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },                          
        {                   --水牛
            ID = 4100,
            Name = "Game4100",
            size = cc.size(390,320),
            desc = "水牛",
            imagePath = "Lobby/Entry/Game4100.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }
    },
    [15] = {                      
        {                   --花木兰
            ID = 8600,
            Name = "Game8600",
            size = cc.size(390,320),
            desc = "花木兰",
            imagePath = "Lobby/Entry/Game8600.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },    
        {                   --咆哮荒野
            ID = 4600,
            Name = "Game4600",
            size = cc.size(390,320),
            desc = "咆哮荒野",
            imagePath = "Lobby/Entry/Game4600.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }
    },
    [16] = {                      
        {                   --白狮
            ID = 4700,
            Name = "Game4700",
            size = cc.size(390,320),
            desc = "白狮",
            imagePath = "Lobby/Entry/Game4700.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },                        
        {                   --海豚之夜
            ID = 5400,
            Name = "Game5400",
            size = cc.size(390,320),
            desc = "海豚之夜",
            imagePath = "Lobby/Entry/Game5400.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }
    },
    [17] = {   
        {                   --森林舞会
            ID = 8700,
            Name = "Game8700",
            size = cc.size(390,320),
            desc = "森林舞会",
            imagePath = "Lobby/Entry/Game8700.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        },
        {                   --开心农场
            ID = 7700,
            Name = "Game7700",
            size = cc.size(390,320),
            desc = "开心农场",
            imagePath = "Lobby/Entry/Game7700.csb",
            Type = GAME_TYPE.API,
            Status = true,
            spineFileName = nil
        }                
    }     
}

HallTableViewUIConfig.GAME_TYPE = GAME_TYPE
HallTableViewUIConfig.TitleConfig = TitleConfig
return HallTableViewUIConfig