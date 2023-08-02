--
-- Author: zhong
-- Date: 2016-08-04 09:51:55
local login = {}

login.CMD_GP_AccountBind_Exists = 
{
	--目标用户
	{k = "szAccounts", t = "tchar", len = G_NetLength.LEN_ACCOUNTS},
	--用户密码
	{k = "szPassword", t = "tchar", len = G_NetLength.LEN_PASSWORD},
	--机器序列
	{k = "szMachineID", t = "tchar", len = G_NetLength.LEN_MACHINE_ID},
}

----------------------------------------------
--/服务命令
login.MDM_GP_USER_SERVICE				= 3									--用户服务

--账号服务
login.SUB_GP_MODIFY_MACHINE				= 100								--修改机器
login.SUB_GP_MODIFY_LOGON_PASS			= 101								--修改密码
login.SUB_GP_MODIFY_INSURE_PASS			= 102								--修改密码
login.SUB_GP_MODIFY_UNDER_WRITE			= 103								--修改签名

--修改头像
login.SUB_GP_USER_FACE_INFO				= 120								--头像信息
login.SUB_GP_SYSTEM_FACE_INFO			= 122								--系统头像
login.SUB_GP_CUSTOM_FACE_INFO			= 123								--自定头像

--个人资料
login.SUB_GP_USER_INDIVIDUAL			= 140								--个人资料
login.SUB_GP_QUERY_INDIVIDUAL			= 141								--查询信息
login.SUB_GP_MODIFY_INDIVIDUAL			= 152								--修改资料
login.SUB_GP_INDIVIDUAL_RESULT			= 153								--完善资料
login.SUB_GP_REAL_AUTH_QUERY			= 154								--认证请求
login.SUB_GP_REAL_AUTH_RESULT			= 155								--认证结果

--银行服务
login.SUB_GP_USER_ENABLE_INSURE			= 160								--开通银行
login.SUB_GP_USER_SAVE_SCORE			= 161								--存款操作
login.SUB_GP_USER_TAKE_SCORE			= 162								--取款操作
login.SUB_GP_USER_TRANSFER_SCORE		= 163								--转账操作
login.SUB_GP_USER_INSURE_INFO			= 164								--银行资料
login.SUB_GP_QUERY_INSURE_INFO			= 165								--查询银行
login.SUB_GP_USER_INSURE_SUCCESS		= 166								--银行成功
login.SUB_GP_USER_INSURE_FAILURE		= 167								--银行失败
login.SUB_GP_QUERY_USER_INFO_REQUEST	= 168								--查询用户
login.SUB_GP_QUERY_USER_INFO_RESULT		= 169								--用户信息
login.SUB_GP_USER_INSURE_ENABLE_RESULT 	= 170								--开通结果	

--签到服务
login.SUB_GP_CHECKIN_QUERY				= 220								--查询签到
login.SUB_GP_CHECKIN_INFO				= 221								--签到信息
login.SUB_GP_CHECKIN_DONE				= 222								--执行签到
login.SUB_GP_CHECKIN_RESULT				= 223								--签到结果

--任务服务
login.SUB_GP_TASK_LOAD					= 240								--任务加载
login.SUB_GP_TASK_TAKE					= 241								--任务领取
login.SUB_GP_TASK_REWARD				= 242								--任务奖励
login.SUB_GP_TASK_GIVEUP				= 243								--任务放弃
login.SUB_GP_TASK_INFO					= 250								--任务信息
login.SUB_GP_TASK_LIST					= 251								--任务信息
login.SUB_GP_TASK_RESULT				= 252								--任务结果
login.SUB_GP_TASK_GIVEUP_RESULT			= 253								--放弃结果



--推广服务
login.SUB_GP_SPREAD_QUERY				= 280								--推广奖励
login.SUB_GP_SPREAD_INFO				= 281								--奖励参数

--等级服务
login.SUB_GP_GROWLEVEL_QUERY			= 300								--查询等级
login.SUB_GP_GROWLEVEL_PARAMETER		= 301								--等级参数
login.SUB_GP_GROWLEVEL_UPGRADE			= 302								--等级升级

--兑换服务
login.SUB_GP_EXCHANGE_QUERY				= 320								--兑换参数
login.SUB_GP_EXCHANGE_PARAMETER			= 321								--兑换参数
login.SUB_GP_PURCHASE_MEMBER			= 322								--购买会员
login.SUB_GP_PURCHASE_RESULT			= 323								--购买结果
login.SUB_GP_EXCHANGE_SCORE_BYINGOT		= 324								--兑换游戏币
login.SUB_GP_EXCHANGE_SCORE_BYBEANS		= 325								--兑换游戏币
login.SUB_GP_EXCHANGE_RESULT			= 326								--兑换结果

--会员服务
login.SUB_GP_MEMBER_PARAMETER			= 340								--会员参数
login.SUB_GP_MEMBER_QUERY_INFO			= 341								--会员查询
login.SUB_GP_MEMBER_DAY_PRESENT			= 342								--会员送金
login.SUB_GP_MEMBER_DAY_GIFT			= 343								--会员礼包
login.SUB_GP_MEMBER_PARAMETER_RESULT	= 350								--参数结果
login.SUB_GP_MEMBER_QUERY_INFO_RESULT	= 351								--查询结果
login.SUB_GP_MEMBER_DAY_PRESENT_RESULT	= 352								--送金结果
login.SUB_GP_MEMBER_DAY_GIFT_RESULT		= 353								--礼包结果

--抽奖服务
login.SUB_GP_LOTTERY_CONFIG_REQ			= 360								--请求配置
login.SUB_GP_LOTTERY_CONFIG				= 361								--抽奖配置
login.SUB_GP_LOTTERY_USER_INFO			= 362								--抽奖信息
login.SUB_GP_LOTTERY_START				= 363								--开始抽奖
login.SUB_GP_LOTTERY_RESULT				= 364								--抽奖结果

--游戏服务
login.SUB_GP_QUERY_USER_GAME_DATA		= 370								--查询数据	

--帐号绑定
login.SUB_GP_ACCOUNT_BINDING			= 380								--帐号绑定

--操作结果
login.SUB_GP_OPERATE_SUCCESS			= 500								--操作成功
login.SUB_GP_OPERATE_FAILURE			= 501								--操作失败

-----------------------------
--用户服务

--用户头像
login.CMD_GP_UserFaceInfo = 
{
	--头像标识
	{k = "wFaceID", t = "word"},
	--自定标识
	{k = "dwCustomID", t = "dword"}
}

--系统头像 修改头像
login.CMD_GP_SystemFaceInfo = 
{
	--头像标识
	{k = "wFaceID", t = "word"},
	--用户id
	{k = "dwUserID", t = "dword"},
	--用户密码
	{k = "szPassword", t = "tchar", s = G_NetLength.LEN_PASSWORD},
	--机器序列
	{k = "szMachineID", t = "tchar", s = G_NetLength.LEN_MACHINE_ID},
}

--自定头像 修改头像
login.CMD_GP_CustomFaceInfo = 
{
	--用户id
	{k = "dwUserID", t = "dword"},
	--用户密码
	{k = "szPassword", t = "tchar", s = G_NetLength.LEN_PASSWORD},
	--机器序列
	{k = "szMachineID", t = "tchar", s = G_NetLength.LEN_MACHINE_ID},
	--图片信息
	{k = "dwCustomFace", t = "ptr", s = 48 * 48 * 4}
}

-- 绑定机器
login.CMD_GP_ModifyMachine = 
{
	-- 绑定标志
	{ t = "byte", k = "cbBind" },
	-- 用户标识
	{ t = "dword", k = "dwUserID"},
	--用户密码
	{ t = "tchar", k = "szPassword", s = G_NetLength.LEN_PASSWORD},
	--机器序列
	{ t = "tchar", k = "szMachineID", s = G_NetLength.LEN_MACHINE_ID},
}

-- 个人资料
login.CMD_GP_UserIndividual = 
{
	-- 用户uid
	{ t = "dword", k = "dwUserID"},
}

-- 查询信息
login.CMD_GP_QueryIndividual = 
{
	-- 用户uid
	{ t = "dword", k = "dwUserID"},
	-- 用户密码
	{ t = "tchar", k = "szPassword", s = G_NetLength.LEN_PASSWORD},
}

-- 携带信息
login.DTP_GP_UI_ACCOUNTS			 = 1									--用户账号	
login.DTP_GP_UI_NICKNAME			 = 2									--用户昵称
login.DTP_GP_UI_USER_NOTE			 = 3									--用户说明
login.DTP_GP_UI_UNDER_WRITE			 = 4									--个性签名
login.DTP_GP_UI_QQ				 	 = 5									--Q Q 号码
login.DTP_GP_UI_EMAIL				 = 6									--电子邮件
login.DTP_GP_UI_SEAT_PHONE			 = 7									--固定电话
login.DTP_GP_UI_MOBILE_PHONE		 = 8									--移动电话
login.DTP_GP_UI_COMPELLATION		 = 9									--真实名字
login.DTP_GP_UI_DWELLING_PLACE		 = 10									--联系地址
login.DTP_GP_UI_PASSPORTID    		 = 11									--身份标识
login.DTP_GP_UI_SPREADER			 = 12									--推广标识

-----------------------------
--银行服务

--银行资料
login.CMD_GP_UserInsureInfo = 
{
	{k = "cbEnjoinTransfer", t = "byte"},								--转账开关
	{k = "wRevenueTake", t = "word"},									--税收比例
	{k = "wRevenueTransfer", t = "word"},								--税收比例
	{k = "wRevenueTransferMember", t = "word"},							--税收比例
	{k = "wServerID", t = "word"},										--房间标识
	{k = "lUserScore", t = "score"},									--用户金币
	{k = "lUserInsure", t = "score"},									--银行金币
	{k = "lTransferPrerequisite", t = "score"},							--转账条件
}

--查询银行
login.CMD_GP_QueryInsureInfo = 
{
	--用户id
	{k = "dwUserID", t = "dword"},
	--用户密码
	{k = "szPassword", t = "tchar", s = G_NetLength.LEN_PASSWORD},
}

--银行-用户信息
login.CMD_GP_UserTransferUserInfo = 
{
	{k = "dwTargetGameID", t = "dword"},								--目标用户
	{k = "szAccounts", t = "string", s = 32},							--目标用户
}

--搜索会员信息
login.CMD_GP_QueryMemberInfo = {
	{t = "dword",k = "dwUserID"},                                            --自己ID
	{t = "dword",k = "dwQueryGameID"},                                       --要查询的ID
	{k = "szDynamicPass", t = "tchar", s = G_NetLength.LEN_PASSWORD},        --动态密码
}
--返回
login.CMD_GP_QueryMemberInfoResult = {
	{t = "dword",k = "dwErrorCode"},                                         --用户ID
	{t = "dword",k = "dwGameID"},                                            --目标游戏ID
	{t = "dword",k = "dwUserID"},                                            --自己ID
	{t = "word",k = "wFaceID"},                                              --目标头像ID
	{t = "word",k = "wMemberOrder"},                                         --目标头像ID
	{t = "tchar", k = "szNickName", s = G_NetLength.LEN_NICKNAME},			 --用户昵称
    {t = "score", k = "lJoinDate"},
	{t = "char", k = "szFaceUrl", s = G_NetLength.LEN_FACEURL},				 --用户头像地址
}

login.SUB_GP_QUERY_TRANSFER_USERS          = 178                        --查询转过账的币商列表
login.SUB_GP_QUERY_TRANSFER_USERS_RESULT   = 179                        --返回
login.CMD_GP_QueryTransableUsers = 
{
	{k = "dwPageSize", t = "dword"},
	{k = "dwPageIndex", t = "dword"},
	--用户id
	{k = "dwUserID", t = "dword"},
	--动态密码
	{k = "szDynamicPass", t = "tchar", s = G_NetLength.LEN_PASSWORD},
}

login.tagChildUserItem = {
	{t = "dword", k = "dwUserID"},
	{t = "dword", k = "dwGameID"},
	{t = "tchar", k = "szNickName", s = G_NetLength.LEN_NICKNAME},				--用户昵称
	{t = "dword", k = "dwFaceID"},
}

--查询可转账的用户列表 结果
login.CMD_GP_QueryTransableUsersResult={
	{t = "dword", k = "dwErrorCode"},
	{t = "dword", k = "dwPageSize"},                                   --每页数量
	{t = "dword", k = "dwPageIndex"},                                  --当前页码
	{t = "dword", k = "dwRecordCount"},                                --全部记录
	{t = "dword", k = "dwPageCount"},                                  --总页数
	{t = "dword", k = "dwCount"},                                  	   --lsItems数量
	{t = "table", k = "lsItems", d = login.tagChildUserItem}          --记录集
}


login.SUB_GP_QUERY_TRANSFER_RECORDS        = 180                        --查询转账记录
login.SUB_GP_QUERY_TRANSFER_RECORDS_RESULT = 181                        --查询转账记录结果
--银行-查询转账记录 
login.CMD_GP_QueryTransferRecords = 
{	

	{k = "dwUserID", t = "dword"},                                 	    --用户id
	{k = "dwTransferType", t = "dword"},                               --1:转入 2:转出
	{k = "dwPageSize", t = "dword"},                                   --每页数量
	{k = "dwPageIndex", t = "dword"},                                  --当前页码
	{k = "szDynamicPass", t = "tchar", s = G_NetLength.LEN_PASSWORD},        --动态密码
}


login.SUB_GP_QUERY_ORDERS                 = 182                       --查询全部充值成功订单
login.SUB_GP_QUERY_ORDERS_RESULT          = 183                       --查询返回结果
login.CMD_GP_QueryOrders = 
{
	{k = "dwUserID", t = "dword"},                                 	    --用户id
	{k = "dwPageSize", t = "dword"},                                  --每页数量
	{k = "dwPageIndex", t = "dword"},                                  --当前页码
	{k = "szDynamicPass", t = "tchar", s = G_NetLength.LEN_PASSWORD},        --动态密码
}

-----------------------------
--任务服务

--任务结果
login.CMD_GP_TaskResult =
{
	--结果信息
	{k = "bSuccessed", t = "bool"},										--成功标识
	{k = "wCommandID", t = "word"},										--命令标识

	--财富信息
	{k = "lCurrScore", t = "score"},									--当前金币
	{k = "lCurrIngot", t = "score"},									--当前元宝

	--提示信息
	{k = "szNotifyContent", t = "string"},								--提示内容
}

----------------------------------------------
login.SUB_GP_QUERY_ORDERS_BY_ORDER_NO        = 184                      --根据订单号查询充值是否完成
login.CMD_GP_QueryOrderByOrderNo = {
	{k = "dwUserID", t = "dword"},                                 	    --用户id
	{k = "szDynamicPass", t = "tchar", s = G_NetLength.LEN_PASSWORD},         --动态密码
	{k = "OrderNo", t = "tchar", s = G_NetLength.LEN_MD5},              --订单号
}
login.SUB_GP_QUERY_ORDERS_BY_ORDER_NO_RESULT = 185                      --是否充值完成返回结果
login.CMD_GP_QueryOrderByOrderNoResult = {
	{k = "Score", t = "score"},									        --充值的金币
	{k = "OrderNo", t = "tchar", s = G_NetLength.LEN_MD5},              --订单号
}

----------------------------------------------
--道具命令
login.MDM_GP_PROPERTY						=	6	

--道具信息
login.SUB_GP_QUERY_PROPERTY					=	1							--道具查询
login.SUB_GP_PROPERTY_BUY					=	2							--购买道具
login.SUB_GP_PROPERTY_USE					=	3							--道具使用
login.SUB_GP_QUERY_BACKPACKET				=	4							--背包查询
login.SUB_GP_PROPERTY_BUFF					=	5							--道具Buff
login.SUB_GP_QUERY_SEND_PRESENT				=	6							--查询赠送
login.SUB_GP_PROPERTY_PRESENT				=	7							--赠送道具
login.SUB_GP_GET_SEND_PRESENT				=	8							--获取赠送

login.SUB_GP_QUERY_PROPERTY_RESULT			=	101							--道具查询
login.SUB_GP_PROPERTY_BUY_RESULT			=	102							--购买道具
login.SUB_GP_PROPERTY_USE_RESULT			=	103							--道具使用
login.SUB_GP_QUERY_BACKPACKET_RESULT		=	104							--背包查询
login.SUB_GP_PROPERTY_BUFF_RESULT			=	105							--道具Buff
login.SUB_GP_QUERY_SEND_PRESENT_RESULT		=	106							--查询赠送
login.SUB_GP_PROPERTY_PRESENT_RESULT		=	107							--赠送道具
login.SUB_GP_GET_SEND_PRESENT_RESULT		=	108							--获取赠送

login.SUB_GP_QUERY_PROPERTY_RESULT_FINISH	=	201							--道具查询

login.SUB_GP_PROPERTY_FAILURE				=	404							--道具失败
--发送的道具
login.SendPresent = 
{
	{k = "dwUserID", t = "dword"},											--赠送者
	{k = "dwRecvUserID", t = "dword"},										--道具给谁
	{k = "dwPropID", t = "dword"},
	{k = "wPropCount", t = "word"},
	{k = "tSendTime", t = "score"},											--赠送的时间
	{k = "szPropName", t = "string", s = 16},								--道具名称
}

--获取赠送
login.CMD_GP_S_GetSendPresent = 
{
	{k = "wPresentCount", t = "word"}, 										--赠送次数
	{k = "Present", t = "table", d = login.SendPresent}						--道具
}

--道具成功
login.CMD_GP_S_PropertySuccess = --CMD_GP_PropertyBuyResult
{
	--购买信息
	{k = "dwUserID", t = "dword"},										--道具ID
	{k = "dwPropID", t = "dword"},										--道具ID
	{k = "dwPropCount", t = "dword"},									--道具数量	
	{k = "lInsureScore", t = "score"},									--银行存款
	{k = "lUserMedal", t = "score"},									--用户元宝	
	{k = "lLoveLiness", t = "score"},									--魅力值	
	{k = "dCash", t = "double"},										--游戏豆	
	--{k = "cbSuccessed", t = "byte"},									--成功标识	
	{k = "cbCurrMemberOrder", t = "byte"},								--会员等级
	{k = "szNotifyContent", t = "string"},								--提示内容
	
}

--道具失败
login.CMD_GP_PropertyFailure = 
{
	{k = "lErrorCode", t = "score"},									--错误代码
	{k = "szDescribeString", t = "string", s = 256},					--描述信息				
}

--获取赠送
login.CMD_GP_C_GetSendPresent = 
{
	{k = "dwUserID", t = "dword"},										--赠送者
	{k = "szPassword", t = "tchar", s = G_NetLength.LEN_PASSWORD}				--用户密码
}
----------------------------------------------


----------------------------------------------
--登陆命令
login.MDM_MB_LOGON							= 100

--登陆模式
login.SUB_MB_LOGON_OTHERPLATFORM			= 4							--其他登陆

------
--发包结构
login.CMD_MB_LogonOtherPlatform = 
{
	{k = "wModuleID", t = "word"},										--模块标识
	{k = "dwPlazaVersion", t = "dword"},								--广场版本
	{k = "cbDeviceType", t = "byte"},									--设备类型
	--注册信息
	{k = "cbGender", t = "byte"},										--用户性别
	{k = "cbPlatformID", t = "byte"},									--平台编号
	{k = "szUserUin", t = "tchar", s = G_NetLength.LEN_USER_UIN},				--登陆帐号
	{k = "szNickName", t = "tchar", s = G_NetLength.LEN_NICKNAME},				--用户昵称
	{k = "zsCompellation", t = "tchar", s = G_NetLength.LEN_COMPELLATION},		--真实名字
	--连接信息
	{k = "szMachineID", t = "tchar", s = G_NetLength.LEN_MACHINE_ID},			--机器标识
	{k = "szMobilePhone", t = "tchar", s = G_NetLength.LEN_MOBILE_PHONE},		--电话号码
    --wx相关数据
    {k = "szAccessToken", t = "tchar", s = 128},			--wx accesstoken
    {k = "szOpenID", t = "tchar", s = 32},			--sz openid
    {k = "cbIpAddr", t = "byte",l=14}
}

------
--回包结构
--登陆失败
login.CMD_MB_LogonFailure =     
{
	{k = "lResultCode", t = "int"},										--错误代码
	{k = "szDescribeString", t = "string"},								--描述消息
}

-- 操作失败
login.CMD_GP_OperateFailure = 
{
	-- 错误代码
	{t = "int", k = "lResultCode"},
	-- 描述消息
	{t = "string", k = "szDescribeString"},
}

-- 操作成功
login.CMD_GP_OperateSuccess = 
{
	-- 操作代码
	{t = "int", k = "lResultCode"},
	-- 描述消息
	{t = "string", k = "szDescribeString"},
}

-- 首充配置
login.SUB_GP_QUERY_FIRST_CHARGE_CONFIG      = 190           --查询首充配置
login.CMD_GP_QueryFirstChargeConfigs = {
	--empty
}

login.SUB_GP_QUERY_FIRST_CHARGE_CONFIG_RESULT = 191         --查询首充返回结果
login.CMD_GP_QueryFirstChargeConfigsResult = {
	{k = "dwCount", t = "dword"},
	{k = "lsItem", t = "table", d = login.tagFirstChargeConfigInfo}
}

--首充配置
login.tagFirstChargeConfigInfo = {
	{k = "nProductID", t = "int"},                
	{k = "dlPrice", t = "double"},
	{k = "lTotalScore", t = "score"},
	{k = "lRealScore", t = "score"},
	{k = "nPercentRate", t = "int"},
}

--获取充值配置  主命令 ： 100 【MDM_MB_LOGON】
login.SUB_MB_GetProductList             = 111         --获取充值配置列表
login.SUB_MB_GetPayUrlConfig            = 112         --获取充值URL
login.SUB_MB_GetProductListResult       = 115         --充值配置列表返回
login.SUB_MB_GetPayUrlConfigResult      = 116         --充值URL 返回

--请求充值URL
login.CMD_MB_GetPayUrlConfig ={
	--empty
}

--请求配置列表
login.CMD_MB_GetProductList = {
	{k = "wProductType", t = "word"}, 
}
--返回配置列表
login.CMD_GP_QueryProductConfigsResult = {
	{k = "dwCount", t = "dword"},
	{k = "lsItem", t = "table", d = login.tagProductConfigInfo}
}
--商品配置
login.tagProductConfigInfo = {
	{k = "iProductID", t = "int"},             --商品ID          
	{k = "iProductType", t = "int"},           --商品额外送的类型
	{k = "fPrice", t = "float"},               --价格
	{k = "lBaseScore", t = "score"},           --原价金币
	{k = "lRealScore", t = "score"},           --附加赠送后的总金币
	{k = "lAttachScore", t = "score"},         --附件赠送值   iProductType == 1 ：赠送比例[比如：75%]    iProductType==2 ： 赠送金额[比如：1000k] 
}

--请求俱乐部身份
login.CMD_GP_AgentMemberOrder = {
	{t = "dword", k = "dwUserID"},
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},
}

login.CMD_GP_AgentMemberOrderResult = {
	{t = "word", k = "wInAgent"},
	{t = "word", k = "wMemberOrder"},             --身份：0普通，1会长，2.3 用于扩展
}


------------------------------------------------------获取第三方头像地址
login.tUserFaceUrl = {
	{t = "dword", k = "dwUserID"},
}
login.CMD_GP_QueryFaceUrl = {
	{t = "dword", k = "dwUserID"},													--用户标识
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},			--动态密码
	{t = "dword", k = "dwCount"},													--数量
	{t = "table", k = "dwUserIDs",d = login.tUserFaceUrl},						    --用户ID列表
}

login.tagUserFaceUrl = {
	{t = "dword", k = "dwUserID"},													--用户标识
	{t = "tchar", k = "szUrl",s = 0},												
}

login.CMD_GP_QueryFaceUrlResult = {
	{t = "dword", k = "dwErrorCode"},	
	{t = "dword", k = "dwCount"},													--数量
	{t = "table", k = "lsItem", d = login.tagUserFaceUrl}											
}

login.CMD_GP_UpdateFaceUrl = {
	{t = "dword", k = "dwUserID"},	                                                --用户标识
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},			--动态密码
	{t = "tchar", k = "szUrl", s = G_NetLength.LEN_FACEURL}											
}

login.CMD_GP_UpdateFaceUrlResult = {
	{t = "dword", k = "dwErrorCode"},												
}

------------------------任务 EX-----------------------------
--请求任务列表
login.SUB_GP_TASK_LIST_EX = 230             
login.CMD_GP_TaskListEx = {
	{t = "dword", k = "dwUserID"},                                     		--
    {t = "dword", k = "dwTaskTypeMask"},                                    --任务类型掩码
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},        --动态密码
}
--返回
login.SUB_GP_TASK_LIST_EX_RESULT = 231
login.tagTaskInfoEx = {
	{t = "int", k = "iTaskID"},
	{t = "int", k = "iTaskType"},                               --1.新手任务 2.日常任务 3.节日任务
	{t = "int", k = "iTaskStatus"},                               --任务状态 (0进行中/去完成  1为成功未领取奖励   2为已完成(领过奖)  3为已完成但不显示)
	{t = "score", k = "lTaskCurProgress"},                      --当前任务进度
	{t = "score", k = "lTaskMaxProgress"},                      --最大进度
	{t = "word", k = "wTaskOperationType"},                    	--任务操作类型  1.充值 2.进行游戏
	{t = "word", k = "wTaskOperationSubValue"},                	--
	{t = "word", k = "wRewardType"},                           	--奖励类型 1.金币 2.保留
	{t = "score", k = "lRewardValue"},                         	--奖励分值
	{t = "int", k = "iGameKindID"},                         	--游戏种类
	-- {t = "int", k = "iGameServerID"},                         	--0.表示任意房间
	{t = "tchar", k = "szTaskDesc",s = 128},                    --任务描述 定长
}
-- /*  任务类型说明
-- if TaskOperationType = 1 then
-- 		TaskOperationSubValue:1.今日首充 2.今日累计充值
-- 		GameKindID:  无意义
-- 		GameServerID:无意义
-- end else if TaskOperationType = 2 then
-- 		TaskOperationSubValue:1.净赢分 2.赢局 3.总局数，4.下注分 5.返奖
-- 		GameKindID	:游戏种类
-- 		GameServerID:限定房间
-- end else if TaskOperationType = 3 then
-- 		TaskOperationSubValue: 1.首次加入俱乐部，2.每日首次登陆
-- 		GameKindID:  无意义
-- 		GameServerID:无意义
-- end
-- */


login.CMD_GP_TaskListExResult = {
	{t = "dword", k = "dwErrorCode"},
	{t = "dword", k = "dwCount"},                                 --
	{t = "table", k = "lsItems", d = login.tagTaskInfoEx}
}
--提交任务，返回当前类型的任务列表刷新数据
login.SUB_GP_TASK_REWARD_EX = 232
login.CMD_GP_TaskRewardEx = {
	{t = "dword", k = "dwUserID"},                                     		--
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},        --动态密码
	{t = "dword", k = "iTaskID"},
	{t = "tchar", k = "szClientIP",s = 16},                                 --用户IP地址 
	
}
-- 提交任务返回 
login.SUB_GP_TASK_REWARD_EX_RESULT = 233

------------------------任务积分系统-----------------------------------
-- 获取任务活跃度全局配置表
login.SUB_MB_GetTaskActivenessConfig = 1230
login.CMD_MB_GetTaskActivenessConfig = {
	{t='dword',     k='dwUserID'   },                         
}

login.tagTaskActivenessConfig = {
	{t='dword',     k='dwConfigID' },                         -- 配置ID
	{t='dword',     k='dwActiveness'},                        -- 活跃度值
	{t='byte',      k='byRewardType'},                        -- 奖励类型 1为金币(为了扩展)
	{t='score',     k='lRewardValue'},                        -- 奖励分值
}
-- 任务活跃度全局配置数据返回
login.SUB_MB_GetTaskActivenessConfigResult = 1231
login.CMD_MB_GetTaskActivenessConfigResult = {
	{t='dword',     k='dwErrorCode'},                         -- 错误码，不用处理
	{t='word',      k='wCount'     },                         -- 配置条数, 小于等于4
	{t="table",     k = "lsItems", d = login.tagTaskActivenessConfig}
}
  
--查询任务活跃度item
login.SUB_MB_GetUserTaskActivenessStatus = 1232
login.CMD_MB_GetUserTaskActivenessStatus = {
	{t='dword',     k='dwUserID'   },                         
	{t='tchar',     k='szDynamicPass',    s= G_NetLength.LEN_PASSWORD},      
}
  
login.CMD_MB_TaskStatus = {
	{t='dword',     k='dwConfigID' },                         -- 配置ID
	{t='byte',      k='byStatus'   },                         -- 0:不可用;1:可领取;2:已领取
}
--任务item数据返回
login.SUB_MB_GetUserTaskActivenessStatusResult = 1233
login.CMD_MB_GetUserTaskActivenessStatusResult = {
	{t='dword',     k='dwActiveness'},                        -- 当前用户的任务活跃度
	{t='word',      k='wCount'     },                         -- 记录条数 小于等于4
	{t="table",   k= "lsItems",        d=  login.CMD_MB_TaskStatus}
}

--领取奖励
login.SUB_MB_ActivenessReward = 1234
login.CMD_MB_ActivenessReward = {
	{t='dword',     k='dwUserID'   },                         
	{t='tchar',     k='szDynamicPass',    s= G_NetLength.LEN_PASSWORD},      
	{t='dword',     k='dwConfigID' },  
	{t='tchar',     k='szClientIP',       s= 16},                -- 当前客户端IP                       
}

--领取奖励返回
login.SUB_MB_ActivenessRewardResult = 1235
login.CMD_MB_ActivenessRewardResult = {
	{t='dword',     k='dwErrorCode'},                         -- 错误码，0表示成功
	{t='dword',     k='dwConfigID' },                         -- 配置ID
	{t='byte',      k='byRewardType'},                        -- 奖励类型 1为金币(为了扩展)
	{t='score',     k='lRewardValue'},                        -- 奖励分值
} 


--红点数据
login.SUB_MB_GetRedDotStatus = 1240
login.CMD_MB_GetRedDotStatus = {
	{t='dword',     k='dwUserID'},                         -- 用户ID
}

login.SUB_MB_GetRedDotStatusResult = 1241
login.tagReddot = {
	{t='byte',      k='byType'     },                         -- 1.银行转账 2.俱乐部 3.任务状态
	{t='byte',      k='bySubType'  },                         -- 子类型
	{t='byte',      k='byCount'    },                         -- 数量(99+) [1,100)
	{t='byte',      k='byMethod'   },                         -- 处理方式  阅读性质/处理性质,客户端也可自行解释
	{t='byte',      k='byStyle'    },                         -- 风格标识：保留
}
login.CMD_DB_GetRedDotStatusResult = {
	{t='dword',     k='dwErrorCode'},                         -- 错误码，0表示成功
	{t='word',      k='byCount'    },                          --
	{t='table',     k='lsItems',    d = login.tagReddot   },  --                       
}


-------------------------破产补助-------------------------------
--低保服务
login.SUB_GP_BASEENSURE_LOAD			= 260								--加载低保
login.CMD_GP_BaseEnsureLoad = {
	{t='dword',     k='dwUserID'   },                         --用户 I D
}
login.SUB_GP_BASEENSURE_PARAMETER		= 262								--低保参数
login.CMD_GP_BaseEnsureParamter = {
	{t='score',     k='lScoreCondition'},                     --游戏币条件
	{t='score',     k='lScoreAmount'},                        --游戏币数量
	{t='byte',      k='byRestTimes'},                         --领取次数	
}

login.SUB_GP_BASEENSURE_TAKE			= 261								--领取低保
login.CMD_GP_BaseEnsureTake = {
	{t='dword',              k='dwUserID'   },                         --用户 I D
	{t='tchar',              k='szDynamicPass',  s= G_NetLength.LEN_PASSWORD},           --动态密码
	{t='tchar',              k='szMachineID',    s= G_NetLength.LEN_MACHINE_ID},           --机器序列
}

login.SUB_GP_BASEENSURE_RESULT			= 263								--低保结果
login.CMD_GP_BaseEnsureResult = {
	{t='dword',      k='dwErrorCode' },                        --错误码
	{t='score',      k='lGameScore' },                         --本次破产补助领取的金币数
	{t='byte',       k='bCount' },                             --剩余次数
}


----------------------------在线玩家-----------------------

-- 1360  SUB_MB_GetOnlineUserInfo
login.CMD_MB_GetOnlineUserInfo = {
	{t='dword',     k='dwUserID'   },                         
	{t='word',      k='wKindID'    },                   --wKindID = 0 请求所有         
}
  
login.tagOnlineInfo = {
	{t='word',      k='wKindID'    },                         
	{t='word',      k='wSortID'    },                          
	{t='word',      k='wServerKind'    },                        
	{t='dword',     k='dwOnLineCount'},                       
}
--1361
login.CMD_MB_GetOnlineUserInfoResult = {
	{t='word',      k='wCount'     },   
	{t='table',     k='lsItems',       d= login.tagOnlineInfo   },  --                       
}

------------------------跑马灯----------------------------
--1262  获取跑马灯  SUB_MB_GetScrollMessageInfo
login.CMD_MB_GetScrollMessage = {
	{t='dword',     k='dwUserID'   },                         
	{t='dword',     k='dwQueueIndex'},                        
}


login.tagScrollMessageInfo = {
	{t='dword',     k='dwQueueIndex'},                        
	{t='tchar',     k='szNickName' ,    s= G_NetLength.LEN_NICKNAME},        
	{t='score',     k='lScore'     },                         
	{t='word',      k='wKindID'    },                         
}
--1363  跑马灯返回
login.CMD_MB_GetScrollMessageResult = {
	{t='word',      k='wCount'     },      
	{t='table',     k='lsItems',        d= login.tagScrollMessageInfo   },  --                     
}

-----------------------每日分享-------------------------


-- SUB_MB_GetShareConfig 1270			// 查询分享配置
-- SUB_MB_UpdateShareCount 1272        // 更新分享入口点击次数
-- SUB_MB_GetShareReward 1274          // 领取分享奖励
-- SUB_MB_GetShareRestLimits 1276      // 查询可分享剩余次数

-- 查询分享配置
login.CMD_MB_GetShareConfig = {
	{t='dword',     k='dwUserID',            },                         
}

login.CMD_MB_GetShareConfigResult = {
	{t='byte',      k='byShareEnable',       },                         -- 标识客户是否显示图标
	{t='score',     k='lShareScore',         },                         -- 每次分享可得分值
	{t='word',      k='wShareUserLimits',    },                         -- 用户总限制次数
	{t='word',      k='wShareMachineLimits', },                         -- 机器限制次数	
	{t='tchar',     k='szShareUrl',          s=256,},                 -- 分享网址
	{t='tchar',     k='szShareTips',         s=256,},                 -- 前置文字
}
  


--更新分享入口点击次数
login.CMD_MB_UpdateShareCount = {
	{t='dword',     k='dwUserID',            },        
	{t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器码                 
}

--返回更新分享入口点击次数
login.CMD_MB_UpdateShareCountResult = {
	{t='dword',     k='dwErrorCode',         },                         -- 无需处理，总是0
	{t='word',      k='wRestLimits',         },                         -- 剩余有奖励分享次数
}
  
--领取分享奖励
login.CMD_MB_GetShareReward = {
	{t='dword',     k='dwUserID',            },                         
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        
	{t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器码
	{t='tchar',     k='szClientIP',          s=16,},              -- 连接地址
	{t='byte',      k='byShareType',         },                         -- whatsapp = 1
}

--领取分享奖励结果
login.CMD_MB_GetShareRewardResult = {
	{t='dword',     k='dwErrorCode',         },                         -- 错误码
	{t='score',     k='lShareScore',         },                         -- 分享得分
	{t='word',      k='wRestLimits',         },                         -- 剩余有奖励分享次数
}
  
--获取可分享剩余次数
login.CMD_MB_GetShareRestLimits = {
	{t='dword',     k='dwUserID',            },                         
	{t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器码
}

--返回可分享剩余次数
login.CMD_MB_GetShareRestLimitsResult = {
	{t='dword',     k='dwErrorCode',         },                         -- 无需处理，总是0
	{t='word',      k='wRestLimits',         },                         
}

--绑定手机结果
login.CMD_MB_BindMobileResult = {
	{t='dword',     k='dwErrorCode',         },                         -- 错误码
	{t='score',     k='lRewardScore',         },                         -- 奖励		
}

--获取手机绑定状态返回
login.CMD_MB_GetBindMobileStatusResult = {
	{t='byte',		k='boBind'},			--是否已绑定	   1=true,0=false
	{t='byte',		k='boReward'},			--是否领取过奖励	1=true,0=false
	{t='byte',		k='cbCurrencyType'},	--货币类型 1金币 2TC币 当前为常量1
	{t='score',     k='lRewardScore'},      --奖励金币/TC币数目
}
--领取手机绑定奖励返回
login.CMD_MB_GetBindMobileRewardResult = {
	{t='dword',		k='dwErrorCode'},		--错误码 1007 已经领取过奖励
	{t='byte',		k='cbCurrencyType'},	--货币类型 1金币 2TC币 当前为常量1
	{t='score',     k='lRewardScore'},      --奖励金币/TC币数目
}

--获取活动配置数据     1300
login.CMD_MB_GetActivityConfig = {
	{t="dword",k="dwUserID",},
	{t="word", k="wCount",},--需要的最大条数。返回的数据量将小于等于此值
}

login.tagActivityConfig = {
	{t = "tchar", k = "szTitle", s = 64},					--标题
	{t = "tchar", k = "szImgUrlMain", s = 128},				--详情图URL
	{t = "tchar", k = "szImgUrlContent", s = 128},			--轮播图URL
}

-- CMD_GP_QueryTransableUsersResult
--获取活动配置数据     1301
login.CMD_MB_GetActivityConfigResult={
	{t = "dword", k = "dwErrorCode"},
	{t = "word", k = "wCount"},                                  	   --lsItems数量
	{t = "table", k = "lsItems", d = login.tagActivityConfig}          --记录集
}

--获取用户当日流水值，总流水值 1320
login.CMD_MB_GetBetScore = {
	{t='dword',     k='dwUserID',},                         --UserID
	{t='byte',      k='cbCurrencyType',},                   --货币类型 1 金币 2 TC币
}

--获取用户当日流水值，总流水值返回 1321
login.CMD_MB_GetBetScoreResult = {
	{t='byte',      k='cbCurrencyType',       },             -- 货币类型
	{t='score',     k='TodayBetScore',        },             -- 当日下注分合计（可只使用这个）
	{t='score',     k='TodayWinScore',        },             -- 当日返奖分合计
	{t='score',     k='TotalBetScore',        },             -- 历史下注分合计(含当日)
	{t='score',     k='TotalWinScore',        },             -- 历史返奖分合计(含当日)
	{t='score',     k='TodayRechargeScore',   },             -- 当日充值分值
}

--查询用户最后一次充值订单信息 1322
login.CMD_MB_GetLastPayInfo = {
	{t='dword',     k='dwUserID',},                         --UserID
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        
	{t='byte',      k='cbCurrencyType',},                   --货币类型 1 金币 2 TC币
}

--查询用户最后一次充值订单信息返回 1323
login.CMD_MB_GetLastPayInfoResult = {
	{t="dword", 	k = "dwErrorCode"		  },
	{t='score',     k='tmDateTime',        	  },            -- 最后充值时间,未充值过，为0 UTC
	{t='dword',     k='dwPayAmount',	       },             -- 支付金额，单位为分
	{t='score',     k='llScore',        	  },            -- 实际购买入账的分数
	{t='dword',     k='dwProductTypeID',	       },             -- 礼包类型ID
	{t='dword',     k='dwProductID',	       },             -- 商品ID	
}

--查询用户VIP信息 1502
login.CMD_MB_GetVIPInfo = {
	{t='dword',     k='dwUserID',},                         --UserID	
	{t='byte',      k='cbExperienceRenderMode',},                   --经验展示类型 1 清空式 2 累加式
}

--查询用户VIP信息返回 1503
login.CMD_MB_GetVIPInfoResult = {
	{t='byte',      k='cbGrowLevel',},                   	--VIP等级
	{t="dword", 	k="dwPayCurrent",},						--当前充值
	{t="dword", 	k="dwPayRequire",},						--需求充值
	{t='score',     k='llBetCurrent',},            			--当前打码
	{t='score',     k='llBetRequire',},			            --需求打码
	{t='word',     k='wDailyAddition',},             		--日转盘加成
	{t='word',     k='wDailyAdditionNext',},             	--日转盘下一级加成
	{t='word',     k='wWeeklyAddition',},             		--周转盘加成
	{t='word',     k='wWeeklyAdditionNext',},             	--周转盘下一级加成
	{t='word',     k='wMonthlyAddition',},             		--月转盘加成
	{t='word',     k='wMonthlyAdditionNext',},              --月转盘下一级加成
}

login.turnTagItem = {
	{t='byte',      k='cbLotteryTypeID'},        
	{t='tchar',      k='szKey',  s = 16 },  
	{t='score',      k='llCondition'},  
	{t='byte',      k='cbPresentCount'} 
}

--返回砸金蛋奖励
login.CMD_MB_GetEggBreakResult = {
	{t='score',     k='llScore',},                         -- 砸金蛋结果
}

login.CMD_MB_GetLotteryPresentConfigResult  = {				--获得转盘帮助系统
	{t='word',      k='wCount'}, 
	{t='table', k = "lsItem",d = login.turnTagItem }
}  

---------------------塔罗牌-------------------------------
--SUB_MB_GetLuckyCardUserStatus, 1610
login.CMD_MB_UserLuckyCardStatus = {
	{t='dword',     k='dwUserId',            },                         --用户id
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},    --动态密码
}
  
login.CMD_MB_UserLuckyCardStatusRes = {
	{t='dword',     k='dwUserId',            },                         --用户id
	{t='byte',      k='cbEnable',            },                         --是否可以用 0 不可以抽奖  1 可以抽奖  2 需要等待倒计时
	{t='int',       k='nTimeLeave',          },                         --等待倒计时时间 
}

--SUB_MB_UserLuckyCardDraw 1612
login.CMD_MB_UserLuckyCardDraw = {
	{t='dword',     k='dwUserId',            },                         --用户id
	{t='byte',      k='cbBetId',             },                         --选择区域id
	{t='tchar',     k='szClientIP',          s=16,},                    -- IP地址
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},    --动态密码
}
  
login.CMD_MB_UserLuckyCardDrawRes = {
	{t='int',       k='nErrorType',          },                         --错误类型  0正常 1 存在异常
	{t='dword',     k='dwUserId',            },                         --用户id
	{t='byte',     k='cbBetId',              },                         --用户选择区域id
	{t='dword',     k='uCurrencyType',       },                         --奖品类型 1金币  2 Tc币
	{t='score',     k='llAwardVule',         },                         --奖品值
	{t='int',       k='nTimeLeave',          },                         --等待倒计时时间
	{t='int',       k='nUseCount',           },                         --已经抽奖次数
}

--请求充值返利信息返回 1581
login.CMD_MB_GetPayRebateInfoResult = {
	{t = 'byte', k = 'cbTodayReward'},				--今天是否已经领取过
	{t = 'word' , k ='wCount'},						--wCount <= 7
	{t = 'score',k = 'llRebateScores'}				--7日奖励列表(含当日)
}  

--领取充值返利奖励 返回 1583
login.CMD_MB_GetPayRebateRewardResult = {
	{t = 'dword', k = 'dwErrorCode'},				--可引发错误(133、134不需要出示给用户，仅开发调用使用)133 没有充值返利可领取134 今天已经领取过了返利	
	{t = 'score',k = 'llRebateScore'}				--此次领取的奖励，用于炸个花，如果错误，值为0
}  


--物品列表项
login.tagShareLotteryItem = {
	{t = 'dword', k = 'dwItemID'},
	{t = 'byte', k = 'cbItemIndex'},
	{t = 'byte', k = 'cbItemType'},
	{t = 'tchar', k = 'szItemName',s=32}
}

--分享转盘物品列表项返回：1701
login.CMD_MB_ShareLotteryGetItemsResult = {
	{t = 'word', k = 'wCount'},				-- wCount===6
	{t = 'table',k = 'lsItems',d = login.tagShareLotteryItem}   --变长格子物品列表
}  

--// 幸运玩家历史记录
login.tagShareLotteryWithdrawHistory = {
	{t = 'word', k = 'wFaceID'},			--头像ID
	{t = 'score', k = 'llScore'},			--奖金
	{t = 'score', k = 'tmRewardDate'},		--时间
	{t = 'tchar', k = 'szNickName',s=G_NetLength.LEN_NICKNAME}
}

--获取幸运玩家历史记录 返回：1705
login.CMD_MB_ShareLotteryGetWithdrawHistoryResult = {
	{t = 'dword', k = 'dwPageSize'},				--每页数量
	{t = 'dword',k = 'dwPageIndex'},   --第几页（从1开始）
	{t = 'dword',k = 'dwPageCount'},   --总页数
	{t = 'dword',k = 'dwRecordCount'},   --记录总数
	{t = 'word',k = 'wCount'},   --当前记录数
	{t = 'table',k = 'lsItems',d = login.tagShareLotteryWithdrawHistory},   -- N条幸运玩家领取记录
} 


--获取玩家状态，用于填满主界面 返回：1703
login.CMD_MB_ShareLotteryGetUserStatusResult= {
	{t = 'score', k = 'llCurrentScore'},			--当前累积的积分
	{t = 'score', k = 'llRequireScore'},			--需要的总现金
	{t = 'dword', k = 'dwRestCount'},		--当前可抽奖的次数
	{t = 'table', k = 'history',d = login.CMD_MB_ShareLotteryGetWithdrawHistoryResult}		--N条幸运玩家领取记录
}

local ShareLotteryUserData = {
	{t = 'word', k = 'wFaceID'},				--角色图标ID(根据图标显示策略显示)
	{t = 'byte',k = 'cbIsBindMobile'},   --是否绑定过手机
	{t = 'byte',k = 'cbIsBetScore'},   --是否达到下注量   ！！！新加的
	{t = 'score',k = 'tmRegisteTime'},   --注册的时间戳
	{t = 'tchar',k = 'szNickName',s=G_NetLength.LEN_NICKNAME}   --昵称
}

-- 获取玩家的邀请记录 返回： 1707
login.CMD_MB_ShareLotteryGetInviteRecordsResult = {
	{t = 'dword', k = 'dwPageSize'},			--每页数量
	{t = 'dword', k = 'dwPageIndex'},			--第几页（从1开始）
	{t = 'dword', k = 'dwPageCount'},		--总页数
	{t = 'dword', k = 'dwRecordCount'},		--记录总数
	{t = 'dword', k = 'dwBindCount'},		--绑定手机的用户数
	{t = 'dword', k = 'dwCount'},		--当前记录数
	{t = 'table', k = 'lsItems',d = ShareLotteryUserData},		--当前记录数
}

-- 旋转转盘 返回： 1709
login.CMD_MB_ShareLotteryExecuteSbinResult = {
	{t = 'dword', k = 'dwErrorCode'},			
	{t = 'byte', k = 'cbItemIndex'},			--中奖的格子号（从0开始）
	{t = 'byte', k = 'cbItemType'},			--中奖的格子类型(见物品定义中的格子类型说明)
	{t = 'score', k = 'llReward'}			--中奖的值(免费次数/金币/现金)
}

-- 目标已达成，领取奖励 返回： 1711
login.CMD_MB_ShareLotteryTakeRewardResult = {
	{t = 'dword', k = 'dwErrorCode'},			
	{t = 'score', k = 'llScore'},			--当前收到的分数，炸花专用
	{t = 'score', k = 'llRequireScore'}			--下一次的需求分数，当前累积的会被清0
}

--七天连续签到领奖返回225
login.CMD_MB_ShareLotteryTakeRewardResult = {
	{t = 'dword', k = 'dwErrorCode'},			
	{t = 'score', k = 'llScore'}			--领取的金额
}
return login