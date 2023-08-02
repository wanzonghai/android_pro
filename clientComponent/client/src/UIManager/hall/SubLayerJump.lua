--[[**
第三方界面跳转
**]]
local luaPath = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.SubLayerConfig")
local SubLayerJump = {}

function SubLayerJump:onAddEventListen()
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_SETLAYER,handler(self,self.onShowSetLayer))  --设置界面 
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_USERINFOLAYER,handler(self,self.onShowUserInfoLayer))--用户信息
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_BANKLAYER,handler(self,self.onOpenBankLayer))--开通银行  
   G_event:AddNotifyEvent(G_eventDef.UI_LOGON_BANKLAYER,handler(self,self.onLogonBankLayer))--登录银行  
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_BANKLAYER,handler(self,self.onShowBankLayer))--进入银行 
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW,handler(self,self.onShowBankLayer_new))--进入新银行 
   G_event:AddNotifyEvent(G_eventDef.UI_MODIFYT_BANKPSDLAYER,handler(self,self.onShowModifyBankPsdLayer)) --修改银行密码
   -- G_event:AddNotifyEvent(G_eventDef.UI_SHOW_GIFTLAYER,handler(self,self.onShowGiftLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_INGOTSLAYER,handler(self,self.onShowIngotsLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_INPUTPHONELAYER,handler(self,self.onShowInputPhoneLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_NOTICELAYER,handler(self,self.onShowNoticeLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_EMAILLAYER,handler(self,self.onShowEmailLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_RANKLAYER,handler(self,self.onShowRankLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_RECHARGELAYER,handler(self,self.onShowRechargeLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CASHOUTLAYER,handler(self,self.onShowCashOutLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CHATLAYER,handler(self,self.onShowChatLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER,handler(self,self.onShowServiceLayer))--客服
    
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_RECORDLAYER,handler(self,self.onShowRecordLayer))  --bank_new 显示记录页


   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBLISTLAYER,handler(self,self.onShowClubListLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBLAYER,handler(self,self.onShowClubLayer))
   --  G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBAPPLYLAYER,handler(self,self.onShowClubApplyLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBMEMBERLAYER,handler(self,self.onShowClubMemberLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBSETLAYER,handler(self,self.onShowClubSetLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBAUDITLISTLAYER,handler(self,self.onShowClubAuditListLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBGUIDELAYER,handler(self,self.onShowClubGuideLayer))
   --  G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBNOTICELAYER,handler(self,self.onShowClubNoticeLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_EDITNOTICELAYER,handler(self,self.onShowClubNoticeLayer))
   --  G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBSIGNLAYER,handler(self,self.onShowClubSignLayer))
   --  G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBTASKLAYER,handler(self,self.onShowClubTaskLayer))


   
   G_event:AddNotifyEvent(G_eventDef.UI_OPEN_CLUBCENTERLAYER,handler(self,self.onShowClubCenterLayer))


   G_event:AddNotifyEvent(G_eventDef.UI_ONCLICK_GAMEKIND,handler(self,self.onClickGameKind))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,handler(self,self.onShowRoomListLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER,handler(self,self.onShowSelectEnterRoomLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_TURNTABLE,handler(self,self.openTurntableLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_TORECORDLAYER,handler(self,self.onShowToRecordLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_OUTRECORDLAYER,handler(self,self.onShowOutRecordLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_TRANSFERUSERLISTLAYER,handler(self,self.onShowTransferUserListLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER,handler(self,self.onShowSignLayer))             --每日签到
   -- G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALLFIRSTGIFTLAYER,handler(self,self.onShowFirstGiftLayer))   --首充
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALLTASKLAYER,handler(self,self.onShowTaskLayer))             --任务
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,handler(self,self.onShowGiftCenterLayer))   --礼包中心
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE,handler(self,self.onShowGiftCodeLayer))   --激活码界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE_SHOP,handler(self,self.onShowGiftCodeShopLayer))   --激活码限时礼包商城界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_BASEENSURE,handler(self,self.onShowBaseEnsureLayer))    --破产补助
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_SHARE,handler(self,self.onShowShareLayer))             --每日分享页
      G_event:AddNotifyEvent(G_eventDef.UI_OPEN_SYSTEM_NOTICE_LAYER,handler(self,self.onShowSystemNoticeLayer))
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_MESSAGE,handler(self,self.onShowMessageLayer))  --短信界面 
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_AUTHEN,handler(self,self.onShowAuthenticatorLayer))  --认证界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_CPF,handler(self,self.onShowCpfLayer))  --CPF界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,handler(self,self.onShowActivityLayer))  --活动详情界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_VIP,handler(self,self.onShowVIPLayer))  --VIP详情界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_VIP_UP,handler(self,self.onShowVIPUpLayer))  --VIP升级界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_PIGGY_BANK,handler(self,self.onShowPiggyBankLayer))  --存钱罐界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_EGG,handler(self,self.onShowEggLayer))  --砸金蛋界面
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_TURNHELP,handler(self,self.onShowTurnHelper))  --转盘活动弹窗
   G_event:AddNotifyEvent(G_eventDef.UI_SHOW_HALL_TAROT,handler(self,self.onShowTarotLayer))  --塔罗牌页面
   G_event:AddNotifyEvent(G_eventDef.UI_SHARETURNTABLE,handler(self,self.onShowShareTurnTable))    --展示分享转盘
   G_event:AddNotifyEvent(G_eventDef.UI_SHARETURNTABLEHISTORY,handler(self,self.onShowShareTurnTableHistory))    --展示分享转盘历史记录
   G_event:AddNotifyEvent(G_eventDef.UI_SHARESTEP,handler(self,self.onShowShareStep))    --展示分享转盘步骤
   G_event:AddNotifyEvent(G_eventDef.UI_SHAREINVITED,handler(self,self.onShowNoTimesAndInvited))    --展示分享转盘不足去邀请好友界面
   G_event:AddNotifyEvent(G_eventDef.TURNTABLE_DESCRIBLE,handler(self,self.onShowTurnTableDescrible))    --转盘次数不够，弹出的框
   G_event:AddNotifyEvent(G_eventDef.CASH_TIPSLAYER,handler(self,self.onShowCashOutTipsLayer))     --提现提示
end

function SubLayerJump:onRemoveListen()
   G_event:RemoveNotifyEvent(G_eventDef.CASH_TIPSLAYER)  --提现提示
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_SETLAYER)  --设置界面 
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_USERINFOLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_BANKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_LOGON_BANKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_BANKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)
    G_event:RemoveNotifyEvent(G_eventDef.UI_MODIFYT_BANKPSDLAYER)
   --  G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_GIFTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_INGOTSLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_INPUTPHONELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_NOTICELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_EMAILLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_RANKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_RECHARGELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CASHOUTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CHATLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBLISTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBAPPLYLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBMEMBERLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBSETLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBAUDITLISTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBGUIDELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBNOTICELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_EDITNOTICELAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBSIGNLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_CLUBTASKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_ONCLICK_GAMEKIND)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER)

    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_TORECORDLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_OUTRECORDLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_TRANSFERUSERLISTLAYER)

    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER)
   --  G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALLFIRSTGIFTLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALLTASKLAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER)   --礼包中心
   G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE)   --激活码界面
   G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE_SHOP)   --激活码限时礼包商城界面
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_BASEENSURE)   --
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_SHARE)   --
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_SYSTEM_NOTICE_LAYER)   --  
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_MESSAGE)  --短信界面 
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_AUTHEN)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_CPF)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALL_VIP)    
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALL_VIP_UP)    
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_HALL_PIGGY_BANK)  
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_TURNTABLE)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHOW_TURNHELP)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHARETURNTABLE)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHARETURNTABLEHISTORY)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHARESTEP)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SHAREINVITED)
    G_event:RemoveNotifyEvent(G_eventDef.TURNTABLE_DESCRIBLE)
end
--设置界面
function SubLayerJump:onShowSetLayer(args)
    appdf.req(luaPath.hallSetLayer).new(args)
end
--用户信息界面
function SubLayerJump:onShowUserInfoLayer(args)
    appdf.req(luaPath.hallUserInfoLayer).new(args)
end
--银行
function SubLayerJump:onOpenBankLayer(args)
    --appdf.req(luaPath.openBankLayer).new(args)
    appdf.req(luaPath.openBankLayer_new).new(args)
end
function SubLayerJump:onLogonBankLayer(args)
    --appdf.req(luaPath.logonBankLayer).new(args)
    appdf.req(luaPath.logonBankLayer_new).new(args)
end
function SubLayerJump:onShowBankLayer(args)
    appdf.req(luaPath.hallBankLayer).new(args)
end
function SubLayerJump:onShowBankLayer_new(args)
    appdf.req(luaPath.hallBankLayer_new).new(args)
end
function SubLayerJump:onShowModifyBankPsdLayer(args)
    appdf.req(luaPath.modifyBankPsdLayer_new).new(args)
   end
   
function SubLayerJump:onShowRecordLayer(args)
   appdf.req(luaPath.bankRecordLayer).new(args)
end
-- function SubLayerJump:onShowGiftLayer(args)
--    appdf.req(luaPath.hallGiftLayer).new(args)
-- end

function SubLayerJump:onShowToRecordLayer(args)
   appdf.req(luaPath.bankToRecordLayer).new(args)
end
function SubLayerJump:onShowOutRecordLayer(args)
   appdf.req(luaPath.bankOutRecordLayer).new(args)
end
function SubLayerJump:onShowTransferUserListLayer(args)
   appdf.req(luaPath.bankTransferUserListLayer).new(args)
end
function SubLayerJump:onShowSignLayer(args)
   appdf.req(luaPath.hallSignLayer).new(args)
end
-- function SubLayerJump:onShowFirstGiftLayer(args)
--    appdf.req(luaPath.hallFirstGiftLayer).new(args)
-- end
function SubLayerJump:onShowTaskLayer(args)
   appdf.req(luaPath.hallTaskLayer).new(args)
end

function SubLayerJump:onShowGiftCenterLayer(args)   
   local parent = cc.Director:getInstance():getRunningScene()
   local pLayer = parent:getChildByName("HallGiftCenterLayer")
   if pLayer then
      return
   end
   appdf.req(luaPath.hallGiftCenterLayer).new(args)
end

function SubLayerJump:onShowGiftCodeLayer(args)   
   local parent = cc.Director:getInstance():getRunningScene()
   local pLayer = parent:getChildByName("GiftCodeLayer")
   if pLayer then
      return
   end
   appdf.req(luaPath.giftCodeLayer).new(args)
end

function SubLayerJump:onShowGiftCodeShopLayer(args)   
   local parent = cc.Director:getInstance():getRunningScene()
   local pLayer = parent:getChildByName("GiftCodeShopLayer")
   if pLayer then
      return
   end
   appdf.req(luaPath.giftCodeShopLayer).new(args)
end

function SubLayerJump:onShowBaseEnsureLayer(args)
   appdf.req(luaPath.hallBaseEnsureLayer).new(args)
end

function SubLayerJump:onShowShareLayer(args)
   appdf.req(luaPath.hallShareLayer).new(args)
end

function SubLayerJump:onShowIngotsLayer(args)
   appdf.req(luaPath.hallIngotsLayer).new(args)
end
function SubLayerJump:onShowInputPhoneLayer(args)
   appdf.req(luaPath.inputPhoneLayer).new(args)
end
function SubLayerJump:onShowNoticeLayer(args)
   appdf.req(luaPath.hallNoticeLayer).new(args)
end
function SubLayerJump:onShowEmailLayer(args)
   appdf.req(luaPath.hallEmailLayer).new(args)
end
function SubLayerJump:onShowRankLayer(args)
   appdf.req(luaPath.hallRankLayer).new(args)
end
function SubLayerJump:onShowRechargeLayer(args)
   appdf.req(luaPath.rechargeLayer).new(args)
end
function SubLayerJump:onShowCashOutLayer(args)
   appdf.req(luaPath.cashoutLayer).new(args)
end
function SubLayerJump:onShowChatLayer(args)
   appdf.req(luaPath.hallChatLayer).new(args)
end
function SubLayerJump:onShowServiceLayer(args)
   appdf.req(luaPath.hallServiceLayer).new(args)
end


function SubLayerJump:onShowClubListLayer(args)
   appdf.req(luaPath.clubListLayer).new(args)
end
function SubLayerJump:onShowClubLayer(args)
   appdf.req(luaPath.clubLayer).new(args)
end
function SubLayerJump:onShowClubApplyLayer(args)
   appdf.req(luaPath.clubApplyLayer).new(args)
end
function SubLayerJump:onShowClubMemberLayer(args)
   appdf.req(luaPath.memberListLayer).new(args)
end
function SubLayerJump:onShowClubSetLayer(args)
   appdf.req(luaPath.clubSetLayer).new(args)
end
function SubLayerJump:onShowClubAuditListLayer(args)
   appdf.req(luaPath.clubAuditListLayer).new(args)
end
function SubLayerJump:onShowClubGuideLayer(args)
   appdf.req(luaPath.clubGuideLayer).new(args)
end
function SubLayerJump:onShowClubNoticeLayer(args)
   appdf.req(luaPath.clubNoticeLayer).new(args)
end
function SubLayerJump:onShowClubSignLayer(args)
   appdf.req(luaPath.clubSignLayer).new(args)
end
function SubLayerJump:onShowClubTaskLayer(args)
   appdf.req(luaPath.clubTaskLayer).new(args)
end

function SubLayerJump:onShowClubCenterLayer(args)
   appdf.req(luaPath.clubCenterLayer).new(args)
end

--系统消息提示页面
function SubLayerJump:onShowSystemNoticeLayer(args)
   appdf.req(luaPath.hallSystemNoticeLayer).new(args)
end

--短信界面
function SubLayerJump:onShowMessageLayer(args)
   appdf.req(luaPath.hallMessageLayer).new(args)
end

--认证界面
function SubLayerJump:onShowAuthenticatorLayer(args)
   appdf.req(luaPath.authenticatorLayer).new(args)
end

--cpf界面
function SubLayerJump:onShowCpfLayer(args)
   appdf.req(luaPath.cpfLayer).new(args)
end

--活动界面
function SubLayerJump:onShowActivityLayer(args)
   appdf.req(luaPath.hallActivityLayer).new(args)
end

--VIP界面
function SubLayerJump:onShowVIPLayer(args)
   appdf.req(luaPath.hallVIPLayer).new(args)
end

--VIP升级界面
function SubLayerJump:onShowVIPUpLayer(args)
   appdf.req(luaPath.hallVIPUpLayer).new(args)
end

--砸金蛋界面
function SubLayerJump:onShowEggLayer(args)
   appdf.req(luaPath.hallEggLayer).new(args)
end

--存钱罐界面
function SubLayerJump:onShowPiggyBankLayer(args)
   appdf.req(luaPath.hallPiggyBankLayer).new(args)
end

--游戏类别
function SubLayerJump:onClickGameKind(args)
    local kind = args.kind  
    appdf.req(luaPath.gameKindLayer[kind]).new(args)
end
--房间列表
function SubLayerJump:onShowRoomListLayer(args)
   appdf.req(luaPath.roomListLayer).new(args)
end

--选择百人场房间类型 金币 or TC
function SubLayerJump:onShowSelectEnterRoomLayer(args)
   appdf.req(luaPath.selectEnterRoomLayer).new(args)
end

--打开抽奖转盘
function SubLayerJump:openTurntableLayer(args)
   appdf.req(luaPath.turntableLayer).new(args)
end

--打开转盘活动帮助界面
function SubLayerJump:onShowTurnHelper(args)
   appdf.req(luaPath.TurnTableHelperLayer).new(args)
end

--打开塔罗牌页面
function SubLayerJump:onShowTarotLayer(args)
   appdf.req(luaPath.HallTarotLayer).new(args)   
end

--打开分享转盘界面
function SubLayerJump:onShowShareTurnTable(args)
   appdf.req(luaPath.shareTurnTableLayer).new(args)   
end

--分享转盘历史记录
function SubLayerJump:onShowShareTurnTableHistory(args)
   appdf.req(luaPath.ShareTurnTableHistory).new(args)   
end

--分享的步骤
function SubLayerJump:onShowShareStep(args)
   appdf.req(luaPath.ShareStepLayer).new(args)   
end

--分享转盘次数不够。去邀请好友的界面
function SubLayerJump:onShowNoTimesAndInvited(args)
   appdf.req(luaPath.ShareConfirm).new(args)   
end

--转盘次数不够，弹出的框
function SubLayerJump:onShowTurnTableDescrible(args)
   appdf.req(luaPath.TurnTableDescrible).new(args)   
end

--提现提示框
function SubLayerJump:onShowCashOutTipsLayer(args)
   appdf.req(luaPath.cashoutTipsLayer).new(args)  
end

return SubLayerJump