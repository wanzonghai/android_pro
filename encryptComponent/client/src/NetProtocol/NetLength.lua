local NetDefine = NetDefine or {}
--游戏类型定义
NetDefine.GAME_TYPE_GOLD						= 0x0001		--金币类型
NetDefine.GAME_TYPE_SCORE						= 0x0002		--点值类型
NetDefine.GAME_TYPE_MATCH						= 0x0004		--比赛类型
NetDefine.GAME_TYPE_EDUCATE				     	= 0x0008		--训练类型
NetDefine.GAME_TYPE_PERSONAL 					= 0x0010 		--约战类型


-- 携带信息
NetDefine.DTP_GP_UI_ACCOUNTS			 = 1									--用户账号	
NetDefine.DTP_GP_UI_NICKNAME			 = 2									--用户昵称
NetDefine.DTP_GP_MEMBER_INFO			 = 2 			                        --会员信息
NetDefine.DTP_GP_UI_USER_NOTE			 = 3									--用户说明
NetDefine.DTP_GP_UI_UNDER_WRITE			 = 4									--个性签名
NetDefine.DTP_GP_UI_QQ				 	 = 5									--Q Q 号码
NetDefine.DTP_GP_UI_EMAIL				 = 6									--电子邮件
NetDefine.DTP_GP_UI_SEAT_PHONE			 = 7									--固定电话
NetDefine.DTP_GP_UI_MOBILE_PHONE		 = 8									--移动电话
NetDefine.DTP_GP_UI_COMPELLATION		 = 9									--真实名字
NetDefine.DTP_GP_UI_DWELLING_PLACE		 = 10									--联系地址
NetDefine.DTP_GP_UI_PASSPORTID    		 = 11									--身份标识
NetDefine.DTP_GP_UI_SPREADER			 = 12									--推广标识

--数据长度定义
NetDefine.LEN_GAME_SERVER_ITEM					= 183			--房间长度
NetDefine.LEN_GAME_SERVER_ITEM_NEW				= 40			--房间长度
NetDefine.LEN_TASK_PARAMETER					= 813			--任务长度
NetDefine.LEN_TASK_STATUS						= 5             --任务长度

NetDefine.LEN_MD5								= 33			--加密密码
NetDefine.LEN_ACCOUNTS							= 32			--帐号长度
NetDefine.LEN_NICKNAME							= 32			--昵称长度
NetDefine.LEN_PASSWORD							= 33			--密码长度
NetDefine.LEN_USER_UIN							= 33
NetDefine.LEN_QQ                                = 16            --Q Q 号码
NetDefine.LEN_EMAIL                             = 33            --电子邮件
NetDefine.LEN_COMPELLATION 				        = 16			--真实名字
NetDefine.LEN_SEAT_PHONE                        = 33            --固定电话
NetDefine.LEN_MOBILE_PHONE                      = 12            --移动电话
NetDefine.LEN_PASS_PORT_ID                      = 19            --证件号码
NetDefine.LEN_COMPELLATION                      = 16            --真实名字
NetDefine.LEN_DWELLING_PLACE                    = 128           --联系地址
NetDefine.LEN_UNDER_WRITE                       = 32            --个性签名
NetDefine.LEN_PHONE_MODE                        = 21            --手机型号
NetDefine.LEN_SERVER                            = 32            --房间长度
NetDefine.LEN_TRANS_REMARK						= 32			--转账备注
NetDefine.LEN_TASK_NAME						    = 64			--任务名称
NetDefine.LEN_FACEURL                           = 256           --头像URL地址

NetDefine.LEN_COMPELLATION						= 16			--真实名字
NetDefine.LEN_MACHINE_ID						= 33			--序列长度
NetDefine.LEN_USER_CHAT						    = 128			--聊天长度
NetDefine.SOCKET_TCP_BUFFER					    = 16384			--网络缓冲

NetDefine.LEN_PRODUCT_TYPE_NAME                 = 16            --商品类型名称长度
NetDefine.LEN_SYSTEM_NOTICE		                = 4000          --系统提示信息长度

return NetDefine