local perPath = "client.src.UIManager.hall.subinterface."
local perClubPath = "client.src.UIManager.hall.club."
local perGameKindPath = "client.src.UIManager.hall.gameKind."
local perBankPath = "client.src.UIManager.hall.bank_new."
local luaPath = {}

luaPath.hallSetLayer = perPath.."HallSetLayer.lua"
luaPath.turntableLayer = perPath.."TurnTable.TurnTableLayer.lua"
luaPath.TurnTableHelperLayer = perPath.."TurnTable.TurnTableHelperLayer.lua"
luaPath.TurnTableDescrible = perPath.."TurnTable.TurnTableDescrible.lua"  --转盘次数不足，点击弹出的框
luaPath.hallUserInfoLayer = perPath.."HallUserInfoLayer.lua"
luaPath.openBankLayer_new = perBankPath.."layer/OpenBankLayer.lua"
luaPath.logonBankLayer_new = perBankPath.."layer/LogonBankLayer.lua"
luaPath.hallBankLayer_new = perBankPath.."layer/bankHallLayer.lua"
luaPath.modifyBankPsdLayer_new = perBankPath.."layer/ModifyBankPsdLayer.lua"
-- luaPath.bankToRecordLayer = perPath.."bank/bankToRecordLayer.lua"         --银行入账记录 
-- luaPath.bankOutRecordLayer = perPath.."bank/bankOutRecordLayer.lua"       --银行转出记录
-- luaPath.bankTransferUserListLayer = perPath.."bank/bankTransferUserListLayer"  --银行历史转账用户列表
luaPath.bankRecordLayer = perBankPath.."layer.bankRecordLayer.lua"        --bank_new 转账记录页 
-- luaPath.hallGiftLayer = perPath.."HallGiftLayer.lua"
luaPath.hallIngotsLayer = perPath.."HallIngotsLayer.lua"
luaPath.inputPhoneLayer = perPath.."InputPhoneLayer.lua"
luaPath.hallNoticeLayer = perPath.."HallNoticeLayer.lua"
luaPath.hallEmailLayer = perPath.."HallEmailLayer.lua"
luaPath.hallRankLayer = perPath.."hallRankLayer.lua"
luaPath.rechargeLayer = perPath.."RechargeLayer.lua"
luaPath.cashoutLayer = perPath.."CashOutLayer.lua"
luaPath.cashoutTipsLayer = perPath.."cashOutTipsLayer.lua"
luaPath.hallChatLayer = perPath.."HallChatLayer.lua"
luaPath.hallServiceLayer = perPath.."HallServiceLayer.lua"  --客服
--俱乐部相关
luaPath.clubListLayer = perClubPath.."layer.ClubListLayer.lua"
luaPath.clubLayer = perClubPath.."layer.ClubHallLayer.lua"
-- luaPath.clubApplyLayer = perClubPath.."ClubApplyLayer.lua"
luaPath.memberListLayer = perClubPath.."layer.MemberListLayer.lua"
luaPath.clubSetLayer = perClubPath.."layer.ClubSetLayer.lua"
luaPath.clubAuditListLayer = perClubPath.."layer.ClubAuditListLayer.lua"
luaPath.clubGuideLayer = perClubPath.."layer.ClubGuideLayer.lua"
luaPath.clubNoticeLayer = perClubPath.."layer.ClubNoticeLayer.lua"
luaPath.clubSignLayer = perClubPath.."ClubSignLayer.lua"
luaPath.clubTaskLayer = perClubPath.."ClubTaskLayer.lua"

luaPath.clubCenterLayer = perClubPath.."layer.ClubCenterLayer.lua"

luaPath.hallSignLayer = perPath.."HallSignLayer.lua"                      --签到
-- luaPath.hallFirstGiftLayer = perPath.."HallFirstGiftLayer.lua"            --首充
luaPath.hallTaskLayer = perPath.."HallTaskLayer.lua"                      --任务
luaPath.hallGiftCenterLayer = perPath.."HallGiftCenterLayer.lua"            --首充
luaPath.hallBaseEnsureLayer = perPath.."HallBaseEnsureLayer.lua"            --破产补助
luaPath.hallShareLayer = perPath.."HallShareLayer.lua"                      --每日分享页
luaPath.hallSystemNoticeLayer = perPath.."HallSystemNoticeLayer.lua"        --系统消息提示页
luaPath.hallMessageLayer = perPath.."authentication/HallMessageLayer.lua"  --短信验证
luaPath.authenticatorLayer = perPath.."authentication/AuthenticatorLayer.lua"  --认证页
luaPath.cpfLayer = perPath.."authentication/CpfLayer.lua"                   --cpf页
luaPath.hallActivityLayer = perPath.."HallActivityLayer.lua"                --活动页
luaPath.hallVIPLayer = perPath.."HallVIPLayer.lua"                --VIP界面
luaPath.hallVIPUpLayer = perPath.."HallVIPUpLayer.lua"                --VIP升级界面
luaPath.hallEggLayer = perPath.."hallEggBreakLayer.lua"                --砸金蛋界面
luaPath.hallPiggyBankLayer = perPath.."PiggyBank/hallPiggyBankLayer.lua"                --存钱罐界面

luaPath.HallTarotLayer = perPath.."HallTarotLayer.lua"                --塔罗牌页面
luaPath.giftCodeLayer = perPath.."GiftCodeLayer.lua"            --激活码界面
luaPath.giftCodeShopLayer = perPath.."GiftCodeShopLayer.lua"            --激活码显示礼包商城界面
luaPath.shareTurnTableLayer = perPath.."ShareTurnTableLayer.lua"            --分享领取转盘
luaPath.ShareTurnTableHistory = perPath.."ShareTurnTableHistory.lua"            --分享领取转盘记录界面
luaPath.ShareStepLayer = perPath.."ShareStepLayer.lua"            --分享转盘步骤记录界面
luaPath.ShareConfirm = perPath.."ShareConfirm.lua"            --分享转盘次数不足，弹出去邀请好友的框

luaPath.gameKindLayer = {}
luaPath.gameKindLayer[1] = perGameKindPath.."GameSlotsLayer.lua"        --街机场
luaPath.gameKindLayer[2] = perGameKindPath.."GameEspecialLayer.lua"       --其他场
luaPath.roomListLayer = perGameKindPath.."RoomListLayer.lua"            --房间列表
luaPath.selectEnterRoomLayer = perPath.."selectEnterRoomLayer.lua"  --百人场选择房间类型 金币 or TC

return luaPath