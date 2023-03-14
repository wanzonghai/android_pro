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

GlobalData.CurEnterTableId = G_NetCmd.INVALID_TABLE
GlobalData.CurEnterChairId = G_NetCmd.INVALID_CHAIR

GlobalData.OldGameID  = {407,520}
GlobalData.HallGameId = {803,703,702,704,901}
GlobalData.SubGameId  = {
    {901,704,532,529,531,528,525,527,502,516},
    -- {122,702,703},
    {702,703,122},
    {520,407},
    {803}
}  --街机，百人，捕鱼，棋牌

GlobalData.EntryConfig = {
    "Activity",--Activity
    {901,704,532,529,531,528,525,527,502,516},--街机类
    {702, 703},--百人类
    {520,407},--捕鱼类
    803,--Truco
    703,--Crash
    702,--Double    
}

GlobalData.RecommendGameID = {901,704,525,527,528,502,516,702,703,122,520,407,803,532,529,531}


GlobalData.ProductInfos = {} --商品列表
GlobalData.ProductsOver = false --商品列表是否完成拉取
GlobalData.GiftEnable   = false --是否允许礼包
GlobalData.ProductOnceState = {0,0,0,0,0,0,0,0,0} --一次性礼包状态,默认不可购买

--当日充值状态是否已经获取完毕
GlobalData.PayInfoOver = false
--当日是否已经充值
GlobalData.TodayPay = false
--当前登录是否已经弹出礼包
GlobalData.NoticeGiftYet = false
--当前登录礼包是否可弹出
GlobalData.NoticeGift = true

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
    [703] = 1,--Crash
    [702] = 1,--Double
    [901] = 1,--Pinko
    [704] = 1,--Frutas
    [532] = 2,--Donzela da Neve
    [529] = 2,--Deus da Fortuna
    [531] = 2,--Carnava

    [525] = false,
    [527] = false,
    [528] = false,
    [502] = false,
    [516] = false,
    [122] = false,
    [520] = false,
    [407] = false,
    [803] = false,
}

--商城小额阈值
GlobalData.ShopThreshold = 10000

--轮询取得渠道名称
GlobalData.ChannelName = ""

--手机绑定信息
GlobalData.BindingInfo = {}

--用户IP地址
GlobalData.MyIP = ""