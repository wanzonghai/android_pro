--全局数据，保存更新或网络拉取的数据
GlobalData = GlobalData or {}

GlobalData.FirstOpenBank                         = true   --第一次打开银行
GlobalData.BankPassword                          = ""     --第一次打开银行记住的密码
GlobalData.BankSelectType                        = 0      --1,是银行，2是礼包
GlobalData.GameReConTime                         = 2      --游戏重连时间
GlobalData.GameReConCount                        = 5      --游戏重连时间

GlobalData.GameConnectSuccess                   = false
GlobalData.HallClickGame                        = false
GlobalData.HallCallback                         = nil     --全局回调

GlobalData.ActiveClose                          = false   --主动关闭socket
GlobalData.ReceiveRoomSuccess                   = false   --接收房间信息成功
GlobalData.ReceiveEGSuccess                   = false   --EG游戏列表信息成功

GlobalData.CurEnterTableId = G_NetCmd.INVALID_TABLE
GlobalData.CurEnterChairId = G_NetCmd.INVALID_CHAIR

GlobalData.OldGameID  = {
    407,--李逵劈鱼
    520,--大闹天宫
}

GlobalData.SubGameId  = {
    {
        --自有 Slots        
        704,--甜蜜富矿
        532,--冰雪女王
        529,--财神到
        531,--嘉年华
        528,--埃及艳后
        525,--九线拉王
        527,--秘鲁传说
        502,--97拳皇
        516,--水浒传
        --EasyGame Slots
        4100,--水牛
        4400,--富贵熊猫
        4600,--咆哮荒野
        4700,--白狮
        5400,--海豚之夜
        5900,--骑士
        6100,--水果机
        6400,--池塘
        7700,--开心农场
        8600,--花木兰
        8700,--森林舞会
    },    
    {
        702,--Double
        703,--Crash
        803,--Truco
        901,--Pinko
        602,--推箱子
        903,--轮盘赌
        520,--大闹天宫
        407,--李逵劈鱼
        122,--百家乐
    },
}

GlobalData.EntryConfig = {
    {
        --自有 Slots        
        704,--甜蜜富矿
        532,--冰雪女王
        529,--财神到
        531,--嘉年华
        528,--埃及艳后
        525,--九线拉王
        527,--秘鲁传说
        502,--97拳皇
        516,--水浒传
        --EasyGame Slots
        4100,--水牛
        4400,--富贵熊猫
        4600,--咆哮荒野
        4700,--白狮
        5400,--海豚之夜
        5900,--骑士
        6100,--水果机
        6400,--池塘
        7700,--开始农场
        8600,--花木兰
        8700,--森林舞会
    }, 
    {
        702,--Double
        703,--Crash
        803,--Truco
        901,--Pinko
        602,--推箱子
        903,--轮盘赌
        520,--大闹天宫
        407,--李逵劈鱼
        122,--百家乐
    },    
    704,--甜蜜富矿
    901,--Pinko
    703,--Crash
    903,--轮盘赌
    525,--九线拉王
    532,--冰雪女王
}

GlobalData.EasyGameID = {
    [4100] = "Búffalo",--水牛
    [4400] = "Fortune Panda",--富贵熊猫
    [4600] = "Roaring Wild",--咆哮荒野
    [4700] = "White Lion",--白狮
    [5400] = "Dolphins Nights",--海豚之夜
    [5900] = "Cavaleiro",--骑士
    [6100] = "Jackpot Diamond",--水果机
    [6400] = "Reel&Spin 2",--池塘
    [7700] = "Happy Farm 2",--开始农场
    [8600] = "Hua Mulan",--花木兰
    [8700] = "Forest Ball",--森林舞会
    [23600] = "Mine",--扫雷
    [27100] = "Penalty",--点球大战
    [27300] = "Dice",   --Dic
    [27400] = "Ball",   --桌球
    [27200] = "Turn",   --转盘
}

GlobalData.ProductInfos = {} --商品列表
GlobalData.ProductsOver = false --商品列表是否完成拉取
GlobalData.GiftEnable   = false --是否允许礼包
GlobalData.First3Times = 1
GlobalData.ProductOnceState = {0,0,0,0,0,0,0,0,0} --一次性礼包状态,默认不可购买

--当日充值状态是否已经获取完毕
GlobalData.PayInfoOver = false
--当日是否已经充值
GlobalData.TodayPay = false

--客服列表 1 whatsapp 2 messenger 3 Telegram
GlobalData.CustomerInfos = {}

--活动列表
GlobalData.ActivityInfos = {}
--TC币 活动对应详情页
GlobalData.TCIndex = -1
--流水 活动对应详情页
GlobalData.BSIndex = -1

--签到进入限制
GlobalData.DailySign = false

--热门游戏配置 1、新游戏配置 2
GlobalData.StatusConfig = {    
    [704]   = 1,--甜蜜富矿
    [532]   = 2,--冰雪女王
    [529]   = 2,--财神到
    [531]   = 2,--嘉年华
    [528]   = false,--埃及艳后
    [525]   = 1,--九线拉王
    [527]   = false,--秘鲁传说
    [502]   = false,--97拳皇
    [516]   = false,--水浒传

    [702]   = 1,--Double
    [703]   = 1,--Crash
    [602]   = 2,--推箱子
    [903]   = 2,--轮盘赌
    [803]   = false,--Truco
    [901]   = 1,--Pinko
    [122]   = false,--百家乐

    [520]   = false,--大闹天宫
    [407]   = false,--李逵劈鱼

    [4100]  = false,--水牛
    [4400]  = false,--富贵熊猫
    [4600]  = false,--咆哮荒野
    [4700]  = false,--白狮
    [5400]  = false,--海豚之夜
    [5900]  = false,--骑士
    [6100]  = false,--水果机
    [6400]  = false,--池塘
    [7700]  = false,--开始农场
    [8600]  = false,--花木兰
    [8700]  = false,--森林舞会

    [23600]  = false,--扫雷
}

--商城小额阈值
GlobalData.ShopThreshold = 10000

--轮询取得渠道名称
GlobalData.ChannelName = ""

--手机绑定信息
GlobalData.BindingInfo = {}

--用户IP地址
GlobalData.MyIP = ""

--转盘数据
GlobalData.TruntableInfo = {}
GlobalData.TruntableEnable   = false --是否允许转盘

--通知消息
GlobalData.Notification = {
    {"Hot:","O jogo mais novo da internet está aqui, jogue com milhares de pessoas online e receba altas recompensas!",},
    {"Roleta da sorte:","iPhone14! AppleWatch! Ganhe agora!"},
    {"Você foi selecionado!","Bônus de até 500 vezes, chances mais altas de ganhar o prêmio, experimente agora!"},
    {"Recompensas de evento:","Desbloqueie mais baús com os bônus em reais já obtidos e os pontos de missão"},
    {"Recompensas de missão:","Complete tarefas simples agora para receber bônus de até R$ 10.000!"},
    {"Recompensas de login:","Logue diariamente! Você ganhará mais recompensas ao acumular 7 dias de login! Entre no jogo agora para verificar!"},
}
