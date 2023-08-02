local NetCmdDefine = NetCmdDefine or {}
-- serverType
NetCmdDefine.GAME_GENRE_GOLD						= 0x0001		--金币类型
NetCmdDefine.GAME_GENRE_SCORE						= 0x0002		--点值类型
NetCmdDefine.GAME_GENRE_MATCH						= 0x0004		--比赛类型
NetCmdDefine.GAME_GENRE_EDUCATE					    = 0x0008		--训练类型
NetCmdDefine.GAME_GENRE_PERSONAL 					= 0x0010 		-- 约战类型

--serverKind
NetCmdDefine.GAME_KIND_GOLD                         = 1            --金币类型
NetCmdDefine.GAME_KIND_TC                           = 4            --TC 类型

NetCmdDefine.SR_ALLOW_AVERT_CHEAT_MODE		    	= 0x00000040	--隐藏信息

NetCmdDefine.MAIN_SOCKET_INFO						= 0

-- NetCmdDefine.SOCKET_CONNECT				    	    = 1
-- NetCmdDefine.SOCKET_ERROR						    = 2
-- NetCmdDefine.SOCKET_CLOSE						    = 3
-- NetCmdDefine.SOCKET_RECONNT                         = 4    --正在重连

NetCmdDefine.EVENT_SUB_SOCKET_CONNECT_HALL         = 1 --大厅连接成功
NetCmdDefine.EVENT_SUB_SOCKET_CONNECT_GAME         = 2 --大厅游戏连接成功
NetCmdDefine.EVENT_SUB_SOCKET_CLOSED_HALL          = 3 --大厅已经关闭
NetCmdDefine.EVENT_SUB_SOCKET_CLOSED_GAME          = 4 --游戏已经关闭
NetCmdDefine.EVENT_SUB_SOCKET_CLOSED_ALL           = 5 --全部l连接关闭
NetCmdDefine.EVENT_SUB_SOCKET_ERROR                = 6 --Socket错误
NetCmdDefine.EVENT_SUB_SOCKET_RECONNT              = 7 --正在重连 

NetCmdDefine.US_NULL								= 0x00		--没有状态
NetCmdDefine.US_FREE								= 0x01		--站立状态
NetCmdDefine.US_SIT								    = 0x02		--坐下状态
NetCmdDefine.US_READY								= 0x03		--同意状态
NetCmdDefine.US_LOOKON							    = 0x04		--旁观状态
NetCmdDefine.US_PLAYING					 		    = 0x05		--游戏状态
NetCmdDefine.US_OFFLINE							    = 0x06		--断线状态
NetCmdDefine.INVALID_TABLE						    = 65535
NetCmdDefine.INVALID_CHAIR						    = 65535
NetCmdDefine.INVALID_ITEM							= 65535
NetCmdDefine.INVALID_USERID						    = 0			--无效用户
NetCmdDefine.INVALID_BYTE                           = 255
NetCmdDefine.INVALID_WORD                           = 65535
--核心协议
NetCmdDefine.MAIN_KERNEL                            = 0             --核心主命令
NetCmdDefine.C_SUB_SOCKET_CONNECT                   = 5           --Socket连接
NetCmdDefine.C_SUB_SOCKET_SHUTDOWN                  = 6           --Socket关闭
--登录相关

NetCmdDefine.MAIN_GP_LOGON					        = 1			    --广场登录
NetCmdDefine.MAIN_MB_LOGON						    = 8			    --广场登录

NetCmdDefine.C_SUB_LOGON_ACCOUNTS			    	= 2			    --帐号登录
NetCmdDefine.C_SUB_REGISTER_ACCOUNTS 	 	        = 3			    --注册帐号
NetCmdDefine.C_SUB_LOGON_OTHERPLATFORM 	 	        = 4			    --其他登录
NetCmdDefine.C_SUB_LOGON_VISITOR					= 5             --游客登录
NetCmdDefine.C_SUB_LOGON_MOBILE 					= 6             --手机登录

NetCmdDefine.C_SUB_SERVER_UTC_TIMESTAMP             = 25            --获取服务器时间戳
NetCmdDefine.S_SUB_SERVER_UTC_TIMESTAMP             = 26            --返回服务器时间戳

NetCmdDefine.S_SUB_LOGON_SUCCESS					= 100			--登录成功
NetCmdDefine.S_SUB_LOGON_FAILURE					= 101			--登录失败
NetCmdDefine.S_SUB_UPDATE_NOTIFY					= 200			--升级提示

--房间相关
NetCmdDefine.MAIN_SERVER_LIST					    = 9			    --列表信息

NetCmdDefine.C_SUB_GET_SERVER_LIST					= 106			--请求游戏列表
NetCmdDefine.S_SUB_LIST_KIND						= 100			--种类列表
NetCmdDefine.S_SUB_LIST_SERVER					    = 101			--房间列表

NetCmdDefine.MAIN_GAME_LIST_TYPE			        = 103           --游戏类型	

NetCmdDefine.S_SUB_GET_SERVER_LIST                  = 406           --请求更新房间数据
NetCmdDefine.S_SUB_UPDATE_MATCH_LIST                = 108           --比赛列表

NetCmdDefine.C_SUB_GET_SERVER_LIST                  = 500           --房间列表数据    
NetCmdDefine.S_SUB_SERVER_LIST_SUCCESS              = 501           --房间列表数据    
NetCmdDefine.S_SUB_SERVER_LIST_FINISH               = 502

NetCmdDefine.MAIN_USER_SERVICE					    = 3 			--用户服务
NetCmdDefine.S_SUB_LIST_FINISH				    	= 200			--列表完成
NetCmdDefine.S_SUB_GetMobileRollNotice              = 106           --公告请求
-- NetCmdDefine.S_SUB_GetOnine	                        = 107           --在线人数
NetCmdDefine.C_SUB_GetScoreInfo                     = 110           --用户金币请求
NetCmdDefine.S_SUB_GetScoreInfo                     = 110           --用户金币请求
NetCmdDefine.C_SUB_GetScoreRank				    	= 109	        --请求排行榜
NetCmdDefine.S_SUB_GetScoreRank				    	= 108	        --返回排行榜
NetCmdDefine.C_SUB_MODIFY_LOGON_PASS				= 101			--修改登录密码
NetCmdDefine.C_SUB_MODIFY_INSURE_PASS			    = 102			--修改银行密码
NetCmdDefine.C_SUB_MODIFY_UNDER_WRITE			    = 103			--修改签名
NetCmdDefine.C_SUB_USER_FACE_INFO			    	= 120			--修改头像信息
NetCmdDefine.S_SUB_USER_FACE_INFO			    	= 120			--修改头像信息
NetCmdDefine.C_SUB_MODIFY_INDIVIDUAL		    	= 152			--修改资料
NetCmdDefine.C_SUB_USER_ENABLE_INSURE		        = 160			--开通银行
NetCmdDefine.C_SUB_USER_SAVE_SCORE				    = 161			--存款操作
NetCmdDefine.C_SUB_USER_TAKE_SCORE				    = 162			--取款操作
NetCmdDefine.C_SUB_USER_INSURE_INFO				    = 164			--银行资料
NetCmdDefine.C_SUB_USER_TRANSFER_SCORE  			= 163 			--转帐操作
NetCmdDefine.C_SUB_QUERY_INSURE_INFO				= 165			--查询银行
-- NetCmdDefine.C_SUB_USER_INSURE_SUCCESS			= 166			--银行成功
NetCmdDefine.C_SUB_USER_INFO_REQUEST	            = 168			--查询用户
NetCmdDefine.C_SUB_GetBankRecord	                = 173			--转账记录

NetCmdDefine.S_SUB_GetBankRecord	                = 113			--转账记录
NetCmdDefine.S_SUB_USER_INSURE_SUCCESS			    = 166			--银行成功
NetCmdDefine.S_SUB_USER_INSURE_FAILURE			    = 167			--银行失败
NetCmdDefine.S_SUB_QUERY_USER_INFO_RESULT		    = 169			--用户信息
NetCmdDefine.S_SUB_USER_INSURE_ENABLE_RESULT 	    = 170			--开通结果

NetCmdDefine.C_SUB_QUERY_TRANSFER_USERS             = 178           --查询转过账的币商列表
NetCmdDefine.C_SUB_QUERY_TRANSFER_RECORDS	        = 180			--转账记录
NetCmdDefine.C_SUB_QUERY_ORDERS                     = 182           --查询全部充值成功订单
NetCmdDefine.S_SUB_GP_QUERY_TRANSFER_USERS_RESULT   = 179           --返回查询转过账的币商列表
NetCmdDefine.S_SUB_GP_QUERY_TRANSFER_RECORDS_RESULT = 181           --查询转账记录结果
NetCmdDefine.S_SUB_QUERY_ORDERS_RESULT              = 183           --查询返回结果

NetCmdDefine.C_SUB_QUERY_ORDERS_BY_ORDER_NO         = 184           --根据订单号查询充值是否完成
NetCmdDefine.S_SUB_QUERY_ORDERS_BY_ORDER_NO_RESULT  = 185           --是否充值完成返回结果

NetCmdDefine.SUB_GP_QUERY_FACE_URL                  = 186			--查询用户头像的第三方链接
NetCmdDefine.SUB_GP_QUERY_FACE_URL_RESULT           = 187

NetCmdDefine.SUB_GP_UPDATE_FACE_URL					= 188	        --更新第三方链接
NetCmdDefine.SUB_GP_UPDATE_FACE_URL_RESULT			= 189

-- 首充配置
NetCmdDefine.C_SUB_QUERY_FIRST_CHARGE_CONFIG        = 190           --查询首充配置
NetCmdDefine.S_SUB_QUERY_FIRST_CHARGE_CONFIG_RESULT = 191          --查询首充返回结果

NetCmdDefine.C_SUB_CHECKIN_QUERY					= 220			--查询签到
NetCmdDefine.S_SUB_CHECKIN_INFO				    	= 221			--签到信息
NetCmdDefine.C_SUB_CHECKIN_DONE					    = 222			--执行签到
NetCmdDefine.S_SUB_CHECKIN_RESULT			    	= 223			--签到结果
NetCmdDefine.SUB_GP_CHECKIN_GET_SERIAL_REWARD       = 224           --领取连续签到奖励
NetCmdDefine.SUB_GP_CHECKIN_GET_SERIAL_REWARD_RESULT  = 225         --领取连续签到奖励返回

--低保服务
NetCmdDefine.C_SUB_BASEENSURE_LOAD				    = 260			--加载低保
NetCmdDefine.C_SUB_BASEENSURE_TAKE				    = 261			--领取低保
NetCmdDefine.S_SUB_BASEENSURE_PARAMETER		    	= 262			--低保参数
NetCmdDefine.S_SUB_BASEENSURE_RESULT				= 263			--低保结果

NetCmdDefine.S_SUB_OPERATE_SUCCESS				    = 500			--操作成功
NetCmdDefine.S_SUB_OPERATE_FAILURE				    = 501			--操作失败

--大厅 游戏推荐动能
-- NetCmdDefine.SUB_MB_LIST_RECOMMEND	                = 1200         --请求：获取推荐游戏种类列表
-- NetCmdDefine.SUB_MB_LIST_RECOMMEND_RESULT	        = 1201         --响应：获取推荐游戏种类列表
-- NetCmdDefine.SUB_MB_UPDATE_RECOMMEND	            = 1202         --请求：更新推荐图标被点击次数，每次点击次数+1
-- NetCmdDefine.SUB_MB_UPDATE_RECOMMEND_RESULT         = 1203         --晌应：更新推荐图标被点击次数，错误无须处理
--礼包系统 包含于商品列表中
NetCmdDefine.SUB_MB_GetProductInfos                 = 1210          --获取商品列表
NetCmdDefine.SUB_MB_GetProductInfosResult           = 1211          --返回：获取商品列表
NetCmdDefine.SUB_MB_GetProductTypeActiveState	    = 1212	        --获取商品类型可否购买状态
NetCmdDefine.SUB_MB_GetProductTypeActiveStateResult	= 1213	        --返回：获取商品类型可否购买状态
NetCmdDefine.SUB_MB_GetPayUrl	                    = 1214			--获取支付URL，可拼凑参数后提交
NetCmdDefine.SUB_MB_GetPayUrlResult                 = 1215			--返回支付URL，可拼凑参数后提交
NetCmdDefine.SUB_MB_GetProductActiveState           = 1216          --获取一次性礼包单个商品状态
NetCmdDefine.SUB_MB_GetProductActiveStateResult     = 1217          --返回一次性礼包单个商品状态
NetCmdDefine.SUB_MB_GetCustomService                = 1250          --获取客服配置
NetCmdDefine.SUB_MB_GetCustomServiceResult          = 1251          --返回客服配置
NetCmdDefine.SUB_MB_GiftCodeActive                 	= 1530          --激活邀请卡
NetCmdDefine.SUB_MB_GiftCodeActiveResult           	= 1531          --返回：激活邀请卡
NetCmdDefine.SUB_MB_GetGiftCodeStatus                 = 1532          --获取激活码限时礼包商品列表
NetCmdDefine.SUB_MB_GetGiftCodeStatusResult           = 1533          --返回：获取激活码限时礼包商品列表
NetCmdDefine.SUB_MB_GetJackPotStatus                = 1560          --获取slots游戏彩金池状态
NetCmdDefine.SUB_MB_GetJackPotStatusResult          = 1561          --返回：获取slots游戏彩金池状态

NetCmdDefine.SUB_MB_GetWithdrawStatus                 = 1220          --获取提现信息
NetCmdDefine.SUB_MB_GetWithdrawStatusResult           = 1221          --返回：获取提现信息
NetCmdDefine.SUB_MB_GetWithdrawConfig                 = 1222          --获取提现额度列表
NetCmdDefine.SUB_MB_GetWithdrawConfigResult           = 1223          --返回：获取提现额度列表
NetCmdDefine.SUB_MB_GetWithdrawHistoryAccount         = 1224          --获取用户提现过的历史账号
NetCmdDefine.SUB_MB_GetWithdrawHistoryAccountResult   = 1225          --返回：获取用户提现过的历史账号
NetCmdDefine.SUB_MB_GetWithdrawRecord                 = 1226          --获取提现记录
NetCmdDefine.SUB_MB_GetWithdrawRecordResult           = 1227          --返回：获取提现记录

NetCmdDefine.SUB_MB_GetOnlineUserInfo               = 1260          --在线人数
NetCmdDefine.SUB_MB_GetOnlineUserInfoResult         = 1261          --在线人数

NetCmdDefine.SUB_MB_GetScrollMessageInfo            = 1262          --跑马灯
NetCmdDefine.SUB_MB_GetScrollMessageInfoResult      = 1263          --跑马灯

NetCmdDefine.SUB_MB_GetShareConfig                  = 1270          -- 查询分享配置
NetCmdDefine.SUB_MB_GetShareConfigResult            = 1271          -- 查询分享配置返回
NetCmdDefine.SUB_MB_UpdateShareCount                = 1272          -- 更新分享入口点击次数
NetCmdDefine.SUB_MB_UpdateShareCountResult          = 1273          -- 更新分享入口点击次数返回
NetCmdDefine.SUB_MB_GetShareReward                  = 1274          -- 领取分享奖励
NetCmdDefine.SUB_MB_GetShareRewardResult            = 1275          -- 领取分享奖励返回
NetCmdDefine.SUB_MB_GetShareRestLimits              = 1276          -- 查询可分享剩余次数
NetCmdDefine.SUB_MB_GetShareRestLimitsResult        = 1277          -- 查询可分享剩余次数返回
NetCmdDefine.SUB_MB_GetSystemNotice          		= 1290          -- 获取系统提示信息
NetCmdDefine.SUB_MB_GetSystemNoticeResult           = 1291          -- 获取系统提示信息返回

NetCmdDefine.SUB_MB_GetActivityConfig               = 1300          --获取活动配置数据
NetCmdDefine.SUB_MB_GetActivityConfigResult         = 1301          --获取活动配置数据结果

-- NetCmdDefine.C_SUB_GetProductList                   = 111         --获取充值配置列表
-- NetCmdDefine.C_SUB_GetPayUrlConfig                  = 112         --获取充值URL
-- NetCmdDefine.S_SUB_GetProductListResult             = 115         --充值配置列表返回
-- NetCmdDefine.S_SUB_GetPayUrlConfigResult            = 116         --充值URL 返回
NetCmdDefine.SUB_MB_UserSaveScoreEx                 = 1310          --存入游戏币
NetCmdDefine.SUB_MB_UserSaveScoreExResult           = 1311          --存入返回
NetCmdDefine.SUB_MB_UserTakeScoreEx                 = 1312          --取出
NetCmdDefine.SUB_MB_UserTakeScoreExTesult           = 1313          --取出返回
NetCmdDefine.SUB_MB_UserTransferScoreEx             = 1314          --转账游戏币
NetCmdDefine.SUB_MB_UserTransferScoreExResult       = 1315          --转账游戏币返回
NetCmdDefine.SUB_MB_GetTransferRecordsEx            = 1316          --查询转账记录 TC银行协议
NetCmdDefine.SUB_MB_TransferRecordsExResult         = 1317          --查询转账记录返回

NetCmdDefine.SUB_MB_GetBetScore                     = 1320          --获取用户当日流水值，总流水值 1320
NetCmdDefine.SUB_MB_GetBetScoreResult               = 1321          --获取用户当日流水值，总流水值返回 1321
NetCmdDefine.SUB_MB_GetLastPayInfo                  = 1322          --查询最后一次充值订单信息 1322
NetCmdDefine.SUB_MB_GetLastPayInfoResult            = 1323          --查询最后一次充值订单信息返回 1323

NetCmdDefine.SUB_MB_GetVIPInfo                      = 1502          --查询用户VIP信息 1502
NetCmdDefine.SUB_MB_GetVIPInfoResult                = 1503          --查询用户VIP信息返回 1503

NetCmdDefine.SUB_MB_GetLotteryCell                  = 1510          --获取转盘格子配置请求
NetCmdDefine.SUB_MB_GetLotteryCellResult            = 1511          --获取转盘格子配置结果
NetCmdDefine.SUB_MB_GetLotteryUserStatus            = 1512          --获取幸运转盘用户配置发送 1512
NetCmdDefine.SUB_MB_GetLotteryUserStatusResult      = 1513          --获取幸运转盘用户配置 返回 1513
NetCmdDefine.SUB_MB_GetLotteryPlatformRecordNewest  = 1514          --获取平台中奖最新广播消息列表 发送 1514
NetCmdDefine.SUB_MB_GetLotteryPlatformRecordResult  = 1515          --获取平台中奖最新广播消息列表 返回 1515
NetCmdDefine.SUB_MB_GetLotteryPlatformRecordHistory = 1516          --获取平台中奖历史广播消息列表 发送 1516
NetCmdDefine.SUB_MB_GetLotteryPlatformRecordHistoryResult  = 1517   --获取平台中奖历史广播消息列表 返回 1517
NetCmdDefine.SUB_MB_GetLotteryUserRecordHistory     = 1518          --获取用户自己中奖历史消息列表 发送 1518
NetCmdDefine.SUB_MB_GetLotteryUserRecordHistoryResult  = 1519       --获取用户自己中奖历史消息列表 返回 1519
NetCmdDefine.SUB_MB_LotterySbin  = 1520       --旋转 发送 1520
NetCmdDefine.SUB_MB_LotterySbinResult  = 1521       --旋转返回 1521
NetCmdDefine.CMD_MB_GetLotteryHelpPresent  = 1522       --获得转盘帮助系统
NetCmdDefine.CMD_MB_GetLotteryHelpPresentResult  = 1523       --获取赠送配置  返回 1523

NetCmdDefine.CMD_MB_GetEggBreak  = 1570             --砸金蛋  请求 1570
NetCmdDefine.CMD_MB_GetEggBreakResult  = 1571       --砸金蛋  返回 1571

NetCmdDefine.CMD_MB_GetPayRebateInfo  = 1580       -- 获取充值返利信息 发送 1580
NetCmdDefine.CMD_MB_GetPayRebateInfoResult  = 1581       --  获取充值返利信息 返回 1581
NetCmdDefine.CMD_MB_GetPayRebateReward   = 1582       -- 领取充值返利奖励 发送 1582
NetCmdDefine.CMD_MB_GetPayRebateRewardResult    = 1583       -- // 领取充值返利奖励 返回 1583

--邮件相关
NetCmdDefine.MDM_GP_MAIL						= 51		-- 主命令 邮件
NetCmdDefine.SUB_GP_MAIL_LIST					= 100		    --邮件列表
NetCmdDefine.SUB_GP_MAIL_LIST_RESULT			= 101         --邮件列表返回
NetCmdDefine.SUB_GP_MAILDETAILS					= 102		    --邮件详情
NetCmdDefine.SUB_GP_MAILDETAILS_RESULT			= 103         --邮件详情返回
NetCmdDefine.SUB_GP_MAIL_DELETE					= 104		    --邮件删除
NetCmdDefine.SUB_GP_MAIL_DELETE_RESULT			= 105         --邮件删除返回
NetCmdDefine.SUB_GP_GETMAILREWARD					= 106		    --邮件领取
NetCmdDefine.SUB_GP_GETMAILREWARD_RESULT			= 107         --邮件领取返回
NetCmdDefine.SUB_GP_GETMAILCOUNT					= 112		    --邮件数量红点
NetCmdDefine.SUB_GP_GETMAILCOUNT_RESULT			= 113         --邮件数量红点返回
--俱乐部相关


--俱乐部相关
NetCmdDefine.MDM_GP_AGENT						= 50		-- 主命令 代理/俱乐部
NetCmdDefine.SUB_GP_AGENT_LIST					= 1		    -- 代理商列表
NetCmdDefine.SUB_GP_AGENT_LIST_RESULT			= 2         --
NetCmdDefine.SUB_GP_AGENT_JOIN					= 3		    -- 加入代理商(俱乐部)
NetCmdDefine.SUB_GP_AGENT_JOIN_RESULT			= 4         --
NetCmdDefine.SUB_GP_AGENT_NOTICE				= 5		    -- 获取公告
NetCmdDefine.SUB_GP_AGENT_NOTICE_RESULT			= 6	        --
NetCmdDefine.SUB_GP_AGENT_KICKOUT				= 7		    -- 创建者将玩家踢出俱乐部
NetCmdDefine.SUB_GP_AGENT_KICKOUT_RESULT		= 8	        --
NetCmdDefine.SUB_GP_AGENT_EXIT					= 9		    -- 玩家主动退出俱乐部
NetCmdDefine.SUB_GP_AGENT_EXIT_RESULT    		= 10	    --
NetCmdDefine.SUB_GP_AGENT_ACCEPT				= 11		-- 同意加人
NetCmdDefine.SUB_GP_AGENT_ACCEPT_RESULT			= 12	    --
NetCmdDefine.SUB_GP_AGENT_UPDATE_NOTICE			= 13		-- 更新公告
NetCmdDefine.SUB_GP_AGENT_UPDATE_NOTICE_RESULT	= 14	    --
NetCmdDefine.SUB_GP_AGENT_MEMBER_LIST			= 15		-- 成员列表
NetCmdDefine.SUB_GP_AGENT_MEMBER_LIST_RESULT	= 16	    --
NetCmdDefine.SUB_GP_AGENT_REFUSE	    		= 17		-- 拒绝加入
NetCmdDefine.SUB_GP_AGENT_REFUSE_RESULT 		= 18		--
NetCmdDefine.SUB_GP_AGENT_SET_SWITCH	    	= 19		-- 设置审核开关
NetCmdDefine.SUB_GP_AGENT_SET_SWITCH_RESULT 	= 20	    --
NetCmdDefine.SUB_GP_AGENT_DETAIL				= 21		-- 获取自己所属俱乐部明细
NetCmdDefine.SUB_GP_AGENT_DETAIL_RESULT			= 22	    --
NetCmdDefine.SUB_GP_AGENT_REQUEST_LIST			= 23		-- 正在申请中的玩家名单列表
NetCmdDefine.SUB_GP_AGENT_REQUEST_LIST_RESULT	= 24
NetCmdDefine.SUB_GP_AGENT_REQUEST_AGENT_LIST    = 25        --已经申请过在审核的公会
NetCmdDefine.SUB_GP_AGENT_REQUEST_AGENT_LIST_RESULT = 26    --

NetCmdDefine.SUB_GP_AGENT_MEMBER_INFO           = 27        --查询会员
NetCmdDefine.SUB_GP_AGENT_MEMBER_INFO_RESULT    = 28        --返回是否有这个会员
NetCmdDefine.SUB_GP_AGENT_UPDATE_URL            = 29        --更新社交群链接
NetCmdDefine.SUB_GP_AGENT_UPDATE_URL_RESULT     = 30        --更新社交群链接结果

NetCmdDefine.SUB_GP_AGENT_MEMBER_ORDER          = 50        --查询公会身份
NetCmdDefine.SUB_GP_AGENT_MEMBER_ORDER_RESULT   = 51        --返回公会身份
NetCmdDefine.SUB_GP_TASK_LIST_EX                = 230       --请求任务列表
NetCmdDefine.SUB_GP_TASK_LIST_EX_RESULT         = 231       --请求任务列表返回
NetCmdDefine.SUB_GP_TASK_REWARD_EX              = 232       --提交任务    返回的是230当前提交任务类型的任务列表数据  刷新当前类型的任务列表
NetCmdDefine.SUB_GP_TASK_REWARD_EX_RESULT       = 233       --数据结构是任务列表 当前类型
NetCmdDefine.SUB_MB_GetTaskActivenessConfig           = 1230      --获取任务活跃度全局配置表
NetCmdDefine.SUB_MB_GetTaskActivenessConfigResult     = 1231      --任务积分系统全局配置数据返回
NetCmdDefine.SUB_MB_GetUserTaskActivenessStatus       = 1232      --查询任务积分item
NetCmdDefine.SUB_MB_GetUserTaskActivenessStatusResult = 1233      --任务item数据返回
NetCmdDefine.SUB_MB_ActivenessReward                  = 1234      --领取某个阶段积分奖励
NetCmdDefine.SUB_MB_ActivenessRewardResult            = 1235      --领取奖励返回
NetCmdDefine.SUB_MB_GetRedDotStatus                   = 1240     --请求红点
NetCmdDefine.SUB_MB_GetRedDotStatusResult             = 1241     --请求红点返回
--游戏相关
NetCmdDefine.MAIN_GAME_LOGON						= 11	        --登录信息
NetCmdDefine.C_GAME_LOGON_MOBILE				    = 2				--手机登录
NetCmdDefine.S_GAME_LOGON_SUCCESS					= 100			--登录成功
NetCmdDefine.S_GAME_LOGON_FAILURE					= 101			--登录失败
NetCmdDefine.S_GAME_LOGON_FINISH					= 102			--登录完成
NetCmdDefine.S_GAME_UPDATE_NOTIFY					= 200			--升级提示
--API游戏接入
NetCmdDefine.S_ENTRY_API_GAME				        = 270			--进入API游戏


NetCmdDefine.MAIN_GAME_CONFIG						= 12			--配置信息
NetCmdDefine.S_GAME_CONFIG_COLUMN					= 100			--列表配置
NetCmdDefine.S_GAME_CONFIG_SERVER					= 101			--房间配置
NetCmdDefine.S_GAME_CONFIG_FINISH					= 102			--配置完成
NetCmdDefine.S_GAME_CONFIG_EXPRESSIONCOST			= 105			--表情价格配置

NetCmdDefine.MAIN_GAME_USER							= 13			--用户信息
NetCmdDefine.C_GAME_USER_SITDOWN					= 3				--坐下请求
NetCmdDefine.C_GAME_USER_STANDUP					= 4				--起立请求
NetCmdDefine.C_GAME_USER_CHAIR_REQ 	   			    = 10 			--请求更换位置
NetCmdDefine.C_GAME_USER_CHAIR_INFO_REQ 	 		= 11 			--请求椅子用户信息
NetCmdDefine.S_GAME_USER_WAIT_DISTRIBUTE			= 12			--等待分配
NetCmdDefine.S_GAME_USER_ENTER					    = 100			--用户进入
NetCmdDefine.S_GAME_USER_SCORE					    = 101			--用户分数
NetCmdDefine.S_GAME_USER_STATUS					    = 102			--用户状态
NetCmdDefine.S_GAME_REQUEST_FAILURE				    = 103			--请求失败
NetCmdDefine.S_GAME_USER_GAME_DATA				    = 104			--用户游戏数据
NetCmdDefine.S_GAMES_USER_EXPRESSION		        = 202			--用户表情

NetCmdDefine.MAIN_GAME_FRAME_STATUS				    = 14			--状态信息
NetCmdDefine.S_GAME_FRAME_TABLE_INFO			    = 100			--桌子信息
NetCmdDefine.S_GAME_FRAME_TABLE_STATUS			    = 101			--桌子状态

NetCmdDefine.DTP_GR_TABLE_PASSWORD				= 1				--桌子密码
NetCmdDefine.DTP_GR_NICK_NAME						= 10			--用户昵称
NetCmdDefine.DTP_GR_UNDER_WRITE					= 12 			--个性签名


NetCmdDefine.MAIN_GAME_INSURE                       = 15			--游戏用户信息
NetCmdDefine.SMT_CLOSE_ROOM						    = 0x0100		--关闭房间
NetCmdDefine.SMT_CLOSE_GAME						    = 0x0200		--关闭游戏
NetCmdDefine.SMT_CLOSE_LINK						    = 0x0400		--中断连接
NetCmdDefine.SMT_CLOSE_INSURE						= 0x0800		--关闭银行


NetCmdDefine.MAIN_GAME_FRAME					    = 100    		--游戏框架命令
NetCmdDefine.C_GAME_FRAME_OPTION			        = 1    		    --游戏配置
NetCmdDefine.C_GAME_FRAME_USER_READY			    = 2    		    --用户准备
NetCmdDefine.C_GAME_FRAME_LOOKON_CONFIG				= 3				--旁观配置
NetCmdDefine.C_GAME_USER_RULE 					    = 1				--用户规则
NetCmdDefine.S_GAMES_USER_CHAT			            = 10			--用户聊天
NetCmdDefine.S_GAMES_USER_VOICE 			        = 12 			--用户语音
NetCmdDefine.S_GAME_FRAME_STATUS					= 100			--游戏状态
NetCmdDefine.S_GAME_FRAME_SCENE					    = 101			--游戏场景
NetCmdDefine.S_GAME_FRAME_LOOKON_STATUS				= 102			--旁观状态
NetCmdDefine.S_GAME_FRAME_SYSTEM_MESSAGE			= 200			--系统消息
NetCmdDefine.S_GAME_FRAME_ACTION_MESSAGE			= 201			--动作消息
NetCmdDefine.S_GAME_FRAME_OUTGAME_MESSAGE			= 203			--踢出消息

NetCmdDefine.MAIN_GAME						        = 200			--游戏命令

NetCmdDefine.SUB_MB_GetSMSUrl						= 1280			--获取短信发送URL
NetCmdDefine.SUB_MB_GetSMSUrlResult					= 1281			--获取短信发送URL返回
NetCmdDefine.SUB_MB_BindMobile					    = 1282			--绑定手机
NetCmdDefine.SUB_MB_BindMobileResult				= 1283			--绑定手机返回

NetCmdDefine.SUB_MB_GetBindMobileStatus				= 1284			--获取手机绑定状态
NetCmdDefine.SUB_MB_GetBindMobileStatusResult		= 1285			--获取手机绑定状态返回
NetCmdDefine.SUB_MB_GetBindMobileReward				= 1286			--领取手机绑定奖励
NetCmdDefine.SUB_MB_GetBindMobileRewardResult		= 1287			--领取手机绑定奖励返回

NetCmdDefine.SUB_MB_GetLuckyCardUserStatus          = 1610          --请求塔罗牌数据
NetCmdDefine.SUB_MB_GetLuckyCardUserStatusResult    = 1611          --返回塔罗牌数据
NetCmdDefine.SUB_MB_UserLuckyCardDraw               = 1612          --请求开启某张牌
NetCmdDefine.SUB_MB_UserLuckyCardDrawResult         = 1613          --返回开牌结果

NetCmdDefine.SHARE_TURNTABLE					    = 1700 			--获取转盘分享物品列表
NetCmdDefine.SHARE_TURNTABLE_RESULT					= 1701 			--获取物品列表返回
NetCmdDefine.SHARE_TURNTABLE_PLAYSTATUS			    = 1702 			--获取玩家状态，用于填满主界面 发送 发送
NetCmdDefine.SHARE_TURNTABLE_PLAYSTATUS_RESULT		= 1703 			--取玩家状态，用于填满主界面 返回
NetCmdDefine.SHARE_TURNTABLE_HISTORY			    = 1704 			--获取幸运玩家历史记录 发送
NetCmdDefine.SHARE_TURNTABLE_HISTORY_RESULT		    = 1705 			--获取幸运玩家历史记录
NetCmdDefine.SHARE_TURNTABLE_PLAYSTATUSRecords	    = 1706 			--获取玩家的邀请记录 发送：1706
NetCmdDefine.SHARE_TURNTABLE_PLAYSTATUSRecords_RESULT  = 1707 			--获取玩家的邀请记录 返回： 1707
NetCmdDefine.CMD_MB_ShareLotteryExecuteSbin         = 1708 			--旋转转盘 发送： 1708
NetCmdDefine.CMD_MB_ShareLotteryExecuteSbinResult   = 1709 			--旋转转盘 返回
NetCmdDefine.CMD_MB_ShareLotteryTakeReward          = 1710 			--目标已达成，领取奖励 发送： 1710
NetCmdDefine.CMD_MB_ShareLotteryTakeRewardResult    = 1711 			--目标已达成，领取奖励 返回： 1711

return NetCmdDefine

