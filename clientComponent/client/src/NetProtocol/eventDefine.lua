-----------------------------------------------------------
-- 日期：	2019
-- 作者:	xxx
-- 描述:	全局定义参数
---------------------------------------------------------
local eventDefine = {}
eventDefine.NET_LOGON_HALL_SUCCESS                 = "net_logon_hall_success"      --用户登录大厅成功
eventDefine.NET_LOGON_HALL_FAILER                  = "net_logon_hall_failer"       --用户登录大厅失败
eventDefine.NET_NETWORK_ERROR                      = "net_network_error"           --网络错误
eventDefine.NET_NEED_RELOGIN                       = "net_need_relogin"            --需要重新登录
eventDefine.NET_GET_RANK_SUCCESS                   = "net_get_rank_success"        --排行榜数据
eventDefine.NET_USER_SCORE_REFRESH                 = "net_user_score_refresh"      --金币刷新
eventDefine.NET_BANK_TRANSFER_DATA                 = "net_bank_transfer_data"      --银行记录
eventDefine.NET_OPEN_BANK_RESULT                   = "net_open_bank_result"        --银行开通结果 
eventDefine.NET_USER_INFO_RESULT                   = "net_user_info_result"        --用户信息
eventDefine.NET_OPERATE_SUCCESS                    = "net_operate_success"         --操作成功
eventDefine.NET_MODIFY_FACE_SUCCESS                = "net_modify_face_success"     --修改头像成功
eventDefine.NET_TRANSFER_MERCHANT_LIST             = "net_transfer_merchant_list"  --转账商家 列表
eventDefine.NET_PAY_ORDER_LIST                     = "net_pay_order_list"          --充值 订单列表
eventDefine.NET_QUERY_CHECKIN                      = "net_query_checkin"           --签到
eventDefine.NET_CHECKIN_RESULT                     = "net_checkin_result"          --签到结果
eventDefine.NET_QUERY_BASEENSURE                   = "net_query_baseensure"        --领取低保结果
-- eventDefine.NET_FIRSTCONFIG_RESULT                 = "net_firstconfig_result"      --首充配置结果
-- eventDefine.NET_USER_PAY_URL                       = "net_user_pay_url"            --用户充值 url返回 
eventDefine.NET_BANK_SAVE_RESULT                   = "net_bank_save_result"         --银行存入返回
eventDefine.NET_BANK_TAKE_RESULT                   = "net_bank_take_result"         --银行取出返回
eventDefine.NET_BANK_TRANSFER_RESULT               = "net_bank_transfer_result"     --银行转账返回
eventDefine.UI_SHOW_RECORDLAYER                    = "ui_show_recordLayer"          --打开记录页

eventDefine.NET_GAMES_USER_EXPRESSION                    = "net_games_user_expression"          --表情，快捷语，互动
eventDefine.UI_OPEN_HUDONG_LAYER                       = "ui_open_huDonglayer"                  --打开互动表情界面

eventDefine.NET_PRODUCTS_RESULT                    = "net_products_result"         --商品列表
eventDefine.NET_PRODUCTS_STATE_RESULT              = "net_products_state_result"   --同步商品表状态结果 
eventDefine.NET_GET_PRODUCT_ACTIVE_STATE_RESULT    = "net_get_product_active_state_result" --同步一次性商品列表状态结果
eventDefine.NET_PAY_URL_RESULT                     = "net_pay_url_result"          --支付URL获取完成事件
eventDefine.NET_QUERY_ORDER_NO_RESULT              = "net_query_order_no_result"   --订单结果 
eventDefine.NET_GIFT_CODE_ACTIVE_RESULT    		   = "net_gift_code_active_result" --激活邀请卡返回
eventDefine.NET_GET_GIFT_CODE_STATUS_RESULT    	   = "net_get_gift_code_status_result" --获取激活码限时礼包商品列表结果
eventDefine.NET_GET_JACK_POT_STATUS_RESULT    	   = "net_get_jack_pot_status_result" --获取slots游戏彩金池状态

eventDefine.NET_WITHDRAW_STATUS_RESULT                    = "net_withdraw_status_result"         --提现信息
eventDefine.NET_WITHDRAW_CONFIG_RESULT                    = "net_withdraw_config_result"         --提现额度列表
eventDefine.NET_WITHDRAW_HISTORY_ACCOUNT_RESULT                    = "net_withdraw_history_account_result"         --提现历史账号
eventDefine.NET_CASHOUT_HISTORY_RESULT                    = "net_cashout_history_result"         --提现记录

eventDefine.UI_GET_SERVER_TIME                     = "ui_get_server_time"          --获取时间
eventDefine.UI_BANK_UPDATE_GOLD                    = "ui_bank_update_gold"         --银行金币更新

eventDefine.EVENT_FACE_URL_RESULT                  = "event_face_url_result"       --获取头像信息返回

eventDefine.NET_MAIL_LIST_RESULT                    = "net_mail_list_result"         --邮件列表返回
eventDefine.NET_MAIL_DETAILS_RESULT                    = "net_mail_details_result"         --邮件详情返回
eventDefine.NET_MAIL_DELETE_RESULT                    = "net_mail_delete_result"         --邮件删除返回
eventDefine.NET_GET_MAIL_REWARD_RESULT                    = "net_get_mail_reward_result"         --邮件领取返回
eventDefine.NET_GET_MAIL_COUNT_RESULT                    = "net_get_mail_count_result"         --邮件数量红点返回

--room
eventDefine.NET_GAME_LIST_FINISH                   = "net_game_list_finish"        --房间完成       
eventDefine.NET_LOGON_ROOM_FAILER                  = "net_logon_failer"            --登录房间失败

eventDefine.UI_THIRD_AUTH_CALLBACK                 = "ui_third_auth_callback"      --第三方授权返回
eventDefine.EVENT_PHONE_SHARE_CALLBACK             = "event_phone_share_callback"  --手机分享返回
eventDefine.UI_SWITCH_ACCOUNT                      = "ui_switch_account"           --切换账号 
eventDefine.UI_GAME_UPDATE                         = "ui_game_update"              --游戏更新
eventDefine.UI_ENTER_GAME_INFO                     = "ui_enter_game_info"          --保存进入的游戏信息
eventDefine.UI_START_GAME                          = "ui_start_game"               --开始游戏
eventDefine.UI_EXIT_TABLE                          = "ui_exit_table"               --退出桌子
eventDefine.UI_REMOVE_GAME_LAYER                   = "ui_remove_game_layer"        --退出游戏
eventDefine.UI_ENTER_GAME_DUOREN                   = "ui_enter_game_duoren"        --多人进入游戏
eventDefine.UI_CONNECT_SUCCESS                     = "ui_connect_success"          --连接成功

--ui sub layer
eventDefine.UI_OPEN_SETLAYER                       = "ui_open_setlayer"                  --显示设置layer
eventDefine.UI_OPEN_USERINFOLAYER                  = "ui_open_userinfolayer"             --用户面板
eventDefine.UI_OPEN_BANKLAYER                      = "ui_open_banklayer"                 --开通银行
eventDefine.UI_LOGON_BANKLAYER                     = "ui_logon_banklayer"                 --
eventDefine.UI_SHOW_BANKLAYER                      = "ui_show_banklayer"
eventDefine.UI_SHOW_BANKLAYER_NEW                  = "ui_show_banklayer_new"
eventDefine.UI_MODIFYT_BANKPSDLAYER                = "ui_modify_bankpsdlayer"
-- eventDefine.UI_SHOW_GIFTLAYER                      = "ui_show_giftlayer"
eventDefine.UI_SHOW_INGOTSLAYER                    = "ui_show_ingotslayer"
eventDefine.UI_SHOW_INPUTPHONELAYER                = "ui_show_inputphonelayer"
eventDefine.UI_OPEN_NOTICELAYER                    = "ui_show_noticelayer"
eventDefine.UI_OPEN_EMAILLAYER                     = "ui_show_emaillayer"
eventDefine.UI_OPEN_RANKLAYER                      = "ui_show_ranklayer"
eventDefine.UI_OPEN_RECHARGELAYER                  = "ui_show_rechargelayer"
eventDefine.UI_OPEN_CASHOUTLAYER                  = "ui_show_cashoutlayer"
eventDefine.UI_OPEN_CHATLAYER                      = "ui_show_chatlayer"
eventDefine.UI_OPEN_SERVICELAYER                   = "ui_open_servicelayer"
eventDefine.UI_SHOW_TORECORDLAYER                  = "ui_show_torecordlayer"             --入账记录
eventDefine.UI_SHOW_OUTRECORDLAYER                 = "ui_show_outrecordlayer"            --出账记录
eventDefine.UI_SHOW_TRANSFERUSERLISTLAYER          = "ui_show_transferUserListlayer"     --转账记录用户列表
-- eventDefine.UI_BANK_TRANSFERRECORD                 = "ui_bank_transferrecord"               --服务器返回查询转账记录结果
eventDefine.UI_BANK_TRANSFERUSERLIST               = "ui_bank_transferuserlist"             --交易过的币商列表
eventDefine.UI_QUERY_ORDERS                        = "ui_query_orders"                      --查询充值成功订单

eventDefine.UI_SHOW_HALLTASKLAYER                  = "ui_show_halltasklayer"
eventDefine.EVENT_TASK_LIST_RESULT                  = "event_task_list_result"
eventDefine.EVENT_TASK_REWARD_RESULT                = "event_task_reward_result"
eventDefine.EVENT_TASK_ACTIVENESS_CONFIG            = "event_task_activeness_config"   
eventDefine.EVENT_TASK_ITEM_DATA_RESULT             = "event_task_item_data_result"
eventDefine.EVENT_TASK_A_REWARD_RESULT              = "event_task_a_reward_result"   
eventDefine.EVENT_REDPOINTDATA_RESULT               = "event_redpointdata_result"

eventDefine.NET_CLUBMEMBERORDER                    = "net_clubMemberOrder"
eventDefine.NET_CLUB_DATA                          = "net_club_data"
eventDefine.NET_BANK_DATA                          = "net_bank_data"

eventDefine.UI_OPEN_CLUBLISTLAYER                  = "ui_show_clublistlayer"
eventDefine.UI_OPEN_CLUBLAYER                      = "ui_show_clublayer"
eventDefine.UI_OPEN_CLUBMEMBERLAYER                = "ui_show_clubmemberlayer"
eventDefine.UI_OPEN_CLUBSETLAYER                   = "ui_show_clubsetlayer"
eventDefine.UI_OPEN_EDITNOTICELAYER                = "ui_show_editNoticeLayer"
eventDefine.UI_OPEN_CLUBAUDITLISTLAYER             = "ui_show_clubauditlistlayer"
eventDefine.UI_OPEN_CLUBGUIDELAYER                 = "ui_show_clubguidelayer"

eventDefine.UI_OPEN_CLUBCENTERLAYER                = "ui_open_clubcenterlayer"                   --打开俱乐部中心

eventDefine.NET_GET_AGENT_DETAIL                   = "net_getAgentDetail"
eventDefine.EVENT_CLUBLISTDATA                     = "event_clublistdata"
eventDefine.EVENT_MEMBERLISTDATA                   = "event_memberlistdata"
eventDefine.EVENT_AGENTJOINRESULT                  = "event_agentJoinResult"
eventDefine.NET_UPDATENOTICE                       = "event_updateNotice"
eventDefine.EVENT_CLUBAUDITSET                     = "event_clubAuditSet"
eventDefine.EVENT_CLUBAUDITLIST                    = "event_clubAuditList"
eventDefine.EVENT_CLUBJOIRESULT                    = "event_clubJoinResult"
eventDefine.NET_REQUESTAGENTLIST                   = "net_requestAgentList"
eventDefine.EVENT_MEMBERINFO                       = "event_memberInfo"
eventDefine.NET_UPDATEURLRESULT                    = "net_updateurlresult"

eventDefine.EVENT_AGENTKICKOUT                     = "event_agentKickout"    
eventDefine.EVENT_AGENTEXIT                        = "event_agentExit"     


eventDefine.EVENT_GAMESCENEFINISH                  = "event_gameSceneFinish"                    --进入游戏完成标志
eventDefine.UI_ONCLICK_GAMEKIND                    = "ui_onclick_gamekind"                      --打开游戏列表
eventDefine.UI_SHOW_ROOMLISTLAYER                  = "ui_show_room_list_layer"                  --打开房间列表
eventDefine.UI_SHOW_SELECTROOMLAYER                = "ui_show_selectEnterRoomLayer"             --打开百人场选择房间类型界面

eventDefine.UI_GAMEKIND_ONEXIT                     = "ui_gamekind_onexit"                       --游戏类型界面退出                                                  
eventDefine.UI_GAMEKIND_ONEXIT_2                   = "ui_gamekind_onexit_2"                     --游戏类型界面退出                                                  
eventDefine.UI_CLIENT_SCENE_NOTICE                 = "ui_client_scene_notice"                   --大厅事件，弹出下一个弹出框
eventDefine.UI_SHOW_HALLSIGNLAYER                  = "ui_show_hallsignlayer"                    --显示签到
eventDefine.UI_SHOW_TURNTABLE                       = "ui_show_turntable"                        --显示转盘
eventDefine.EVENT_TURNTABLE_USERDATA               = "event_turntable_userdata"                 --事件转盘用户配置
eventDefine.EVENT_TURNTABLE_NEWDATALIST            = "event_turntable_newdatalist"              --事件转盘最新广播消息列表
eventDefine.EVENT_TURNTABLE_OLDDATALIST            = "event_turntable_olddatalist"              --事件转盘老的广播消息列表
eventDefine.EVENT_TURNTABLE_USERHISTORYDATA        = "event_turntable_userhistorydata"          --转盘用户历史记录
eventDefine.EVENT_TURNTABLE_REVOLVERESULT          = "event_turntable_resolveresult"            --旋转结果
eventDefine.UI_SHOW_TURNHELP                       = "UI_SHOW_TURNHELP"                         --打开转盘帮助界面
eventDefine.REFRESH_TURNCONFIG                     = "REFRESH_TURNCONFIG"                       --刷新转盘数据
-- eventDefine.UI_SHOW_HALLFIRSTGIFTLAYER             = "ui_show_hallfirstgiftlayer"               --显示首充
-- eventDefine.UI_FIRSTCONFIGRESULT                   = "ui_firstconfigresult"                     --首充配置结果
eventDefine.UPDATE_TURNTABLE                       = "UPDATE_TURNTABLE"                         --转盘货币更新

eventDefine.UI_SHOW_GIFT_CENTER                    = "ui_show_gift_center"                      --礼包中心
eventDefine.UI_SHOW_GIFT_CODE                      = "ui_show_gift_code"                        --激活码界面
eventDefine.UI_SHOW_GIFT_CODE_SHOP                 = "ui_show_gift_code_shop"                   --激活码限时礼包商城界面
eventDefine.UI_SHOW_BASEENSURE                     = "ui_show_baseEnsure"                       --破产补助
eventDefine.EVENT_ON_BASEENSURE_CALLBACK           = "event_on_bassensure_callback"             --领取破产补助成功回调
eventDefine.EVENT_MARQUEE_DATA                     = "event_marquee_data"                       --跑马灯
eventDefine.EVENT_ONLINE_USER_INFO                 = "event_online_user_info"                   --在线玩家

eventDefine.EVENT_SHARE_CONFIG                     = "event_share_config"                       --每日分享配置
eventDefine.EVENT_SHARE_CLICK_COUNT                = "event_share_click_count"                  --分享入口点击次数
eventDefine.EVENT_SHARE_REWARD                     = "event_share_reward"                       --分享奖励
eventDefine.EVENT_SHARE_RESTLIMITS                 = "event_share_restLimits"                   --分享剩余次数
eventDefine.UI_SHOW_SHARE                          = "ui_show_share"                            --打开每日分享页面
eventDefine.EVENT_SCORE_LESS                       = "event_score_less"                         --金币不足
eventDefine.EVENT_SYSTEM_NOTICE_INFO               = "event_system_notice_info"                 --系统提示信息
eventDefine.UI_OPEN_SYSTEM_NOTICE_LAYER            = "ui_open_system_notice_layer"              --打开系统提示信息界面

eventDefine.UI_SHOW_MESSAGE                        = "ui_show_message"                           --打开短信页
eventDefine.UI_SHOW_CPF                            = "ui_show_cpf"                               --打开cpf页
eventDefine.UI_SHOW_AUTHEN                         = "ui_show_authen"                            --打开认证页
eventDefine.EVENT_START_PHONE_LOGIN                 = "event_start_phone_login"                    --开始手机登录
eventDefine.EVENT_BIND_MOBILE_STATUS                = "event_bind_mobile_status"                   --绑定手机状态
eventDefine.EVENT_BIND_MOBILE_RESULT                = "event_bind_mobile_result"                   --绑定手机结果
eventDefine.EVENT_BIND_MOBILE_REWARD                = "event_bind_mobile_reward"                   --绑定手机奖励领取

eventDefine.UPDATE_MSG_TIME                        = "update_msg_time"                           --更新信息时间
eventDefine.EVENT_HALL_ACTIVITY_DATA               = "event_hall_activity_data"                  --活动详情数据
eventDefine.UI_SHOW_HALL_ACTIVITY                  = "ui_show_hall_activity"                     --打开活动详情界面
eventDefine.UI_CLIENT_SCENE_AUTH                   = "ui_client_scene_auth"                      --响应绑定手机点击
eventDefine.EVENT_HALL_BET_SCORE_DATA              = "event_hall_bet_score_data"                 --获取用户当日流水值，总流水值返回数据
eventDefine.EVENT_HALL_LAST_PAY_INFO_DATA          = "event_hall_last_pay_info_data"             --查询最后一次充值订单信息返回数据
eventDefine.UI_SHOW_HALL_VIP                       = "ui_show_hall_vip"                          --打开VIP详情界面
eventDefine.UI_SHOW_HALL_VIP_UP                       = "ui_show_hall_vip_up"                          --打开VIP升级界面
eventDefine.UI_SHOW_HALL_EGG                       = "ui_show_hall_egg"                          --砸金蛋界面
eventDefine.EVENT_EGG_BREAK                       = "event_egg_break"                            --砸金蛋奖励
eventDefine.UI_SHOW_HALL_PIGGY_BANK                       = "ui_show_piggy_bank"                          --存钱罐界面


eventDefine.UI_SHOW_HALL_TAROT                     = "ui_show_hall_tarot"                        --打开塔罗牌页面
eventDefine.EVENT_TAROT_REQUEST                    = "event_tarot_request"                       --请求数据 Request
eventDefine.EVENT_TAROT_OPEN_CARD                  = "event_tarot_open_card"                     --开启牌


--资源下载相关
eventDefine.UI_RESOURCE_DOWN_PROGRESS              = "ui_resource_down_progress"
eventDefine.UI_RESOURCE_DOWN_SUCCESS               = "ui_resource_down_success"
eventDefine.NET_CONNECT_SUCCESS               	   = "net_connect_success"

eventDefine.NET_SMS_URL_RESULT                     = "net_sms_url_result"          --smsURL获取完成事件

eventDefine.RECHARGEBENEFIT                        = "RECHARGEBENEFIT"              --充值返利礼包领取
eventDefine.RECHARGEBENEFIT_INFO                   = "RECHARGEBENEFIT_INFO"          --充值返利信息返回
eventDefine.UI_SHARETURNTABLE                      = "UI_SHARETURNTABLE"            --分享转盘界面
eventDefine.UI_SHARETURNTABLEHISTORY               = "UI_SHARETURNTABLEHISTORY"      --分享转盘界面记录界面
eventDefine.UI_SHARESTEP                          = "UI_SHARESTEP"           --分享转盘步骤界面
eventDefine.UI_SHAREINVITED                          = "UI_SHAREINVITED"           --分享转盘不足去邀请

eventDefine.SHARE_TURN_RECORD                     = "SHARE_TURN_RECORD"           --转盘记录
eventDefine.SHARE_TURN_RESLOVE                    = "SHARE_TURN_RESLOVE"            --旋转返回
eventDefine.SHARE_TURN_RECEIVEGIFT                = "SHARE_TURN_RECEIVEGIFT"        --分享转盘领取
eventDefine.SHARE_TURN_LUCKHISTORY                = "SHARE_TURN_LUCKHISTORY"        --幸运玩家列表
eventDefine.TURNTABLE_DESCRIBLE                   = "TURNTABLE_DESCRIBLE"        --转盘次数不足弹出的框
eventDefine.CASH_CHECKRETURN                      = "CASH_CHECKRETURN"          --提现的时候判断是否充值过
eventDefine.CASH_TIPSLAYER                        = "CASH_TIPSLAYER"          --提现的时候提示框
eventDefine.SIGN_CONTINUE_RESULT                  = "SIGN_CONTINUE_RESULT"      --连续签到返回结果
eventDefine.REFRESH_SEVENDAILY                    = "REFRESH_SEVENDAILY"      --连续签到数据
return eventDefine