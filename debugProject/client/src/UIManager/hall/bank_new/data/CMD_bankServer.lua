--[[
    银行 结构体
]]

local cmd_bank = {}

--操作行为类型
cmd_bank.behaviorType = {
    save = 1,               --存
    take = 2,               --取
    transfer = 3,           --转移
}

--开通银行
-- EnableBank:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_ENABLE_INSURE)
cmd_bank.CMD_MB_EnableBank = {
    {t='dword',     k='dwUserID',            },                         -- 用户 I D
    {t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        -- 登录密码
    {t='tchar',     k='szBankPassward',      s=G_NetLength.LEN_PASSWORD,},        -- 银行密码
    {t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器序列
}
--开通消息返回
cmd_bank.CMD_MB_EnableBankResult = {
    {t='byte',      k='cbInsureEnabled',      },                         -- 开通标志
    {t='tchar',     k='szTipString',       },                            -- 提示消息
}

--修改银行密码
cmd_bank.CMD_MB_ModifyBankPswd = {
  {t='dword',     k='dwUserID',            },                         -- 用户 I D
  {t='tchar',     k='szBankPasswardOld',      s=G_NetLength.LEN_PASSWORD,},        -- 银行旧密码
  {t='tchar',     k='szBankPasswardNew',      s=G_NetLength.LEN_PASSWORD,},        -- 银行新密码
}
--修改银行密码返回
cmd_bank.CMD_MB_ModifyBankPswdResult = {
  {t='word',      k='wSubId',            },                         -- 
  {t='int',       k='lResultCode',            },                     -- 
  {t='tchar',     k='szTips',      s=128,},                        -- 
}

--查询上过分的币商列表
--G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_TRANSFER_USERS
--ServerFrameMgr:C2S_RequestTransferUsers(pageSize,pageIndex,dwUserID,szDynamicPass)
cmd_bank.CMD_MB_TransferUsers = {
	{t='dword',     k='dwPageSize',          },                         -- 每页容量
	{t='dword',     k='dwPageIndex',         },                         -- 页号:从1开始
	{t='dword',     k='dwUserID',            },                         -- 用户 I D
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        -- 登录密码
}


cmd_bank.CMD_MB_TransferItem ={
	{t='dword',     k='dwUserID',          },   
	{t='dword',     k='dwGameID',          },   
	{t="tchar",     k = "szNickName",        s = G_NetLength.LEN_NICKNAME},			 --用户昵称
	{t='dword',     k='dwFaceID',          },   
}

cmd_bank.CMD_MB_TransferUserResult = {
	{t='dword',     k='dwErrorCode',          },   
	{t='dword',     k='dwPageSize',          },   
	{t='dword',     k='dwPageIndex',          },   
	{t='dword',     k='dwRecordCount',          },   
	{t='dword',     k='dwPageCount',          },   
	{t='dword',     k='cbCount',          },   
	{t='lable',     k='lsItems',        d = cmd_bank.CMD_MB_TransferItem  },   
}

--查询成功充值订单
--G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_ORDERS
--ServerFrameMgr:C2S_QueryOrders(dwUserID,pageSize,pageIndex,szDynamicPass)
cmd_bank.CMD_MB_Orders = {
	{t='dword',     k='dwUserID',            },                         -- 用户 I D
	{t='dword',     k='dwPageSize',          },                         -- 每页容量
	{t='dword',     k='dwPageIndex',         },                         -- 页号:从1开始
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},  -- 动态密码
}

--搜索会员信息
--G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_MEMBER_INFO
--ServerFrameMgr:C2S_RequesMemberInfo(GameID)
cmd_bank.CMD_MB_MemberInfo = {
	{t='dword',     k='dwUserID',            },                             -- 用户 I D
	{t='dword',     k='dwGameID',            },                             -- 查询会员的 I D
	{t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},  -- 动态密码
}

--返回
cmd_bank.CMD_GP_QueryMemberInfoResult = {
	{t = "dword", k = "dwErrorCode"  },                                      --用户ID
	{t = "dword", k = "dwGameID"     },                                      --目标游戏ID
	{t = "dword", k = "dwUserID"     },                                      --自己ID
	{t = "word",  k = "wFaceID"      },                                      --目标头像ID
	{t = "word",  k = "wMemberOrder" },                                      --目标头像ID
	{t = "tchar", k = "szNickName", s = G_NetLength.LEN_NICKNAME},			 --用户昵称
    {t = "score", k = "lJoinDate"    },
	{t = "char",  k = "szFaceUrl",  s = G_NetLength.LEN_FACEURL},			 --用户头像地址
}



--存入游戏币 CMD: 1310
cmd_bank.CMD_MB_UserSaveScoreEx = {
    {t='dword',     k='dwUserID',            },                         -- 用户 I D
    {t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        -- 登录密码
    {t='byte',      k='cbCurrencyType',      },                         -- 1金币，2TC币
    {t='score',     k='llScore',             },                         -- 存入游戏币
    {t='dword',     k='dwClientAddr',        },                         -- 连接地址
    {t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器序列
}
--银行存入返回 CMD: 1311
cmd_bank.CMD_MB_UserSaveScoreExResult = {
    {t='dword',     k='dwResultCode',        },                         -- 错误代码，可能引发错误 10103 币值不足
    {t='byte',      k='cbCurrencyType',      },                         -- 货币类型: 1金币 2TC币
    {t='score',     k='llScore',             },                         -- 货币值 用于冒花特效
}
--取出游戏币(与存入游戏币结构相同)  CMD: 1312
cmd_bank.CMD_MB_UserTakeScoreEx = {
    {t='dword',     k='dwUserID',            },                         -- 用户ID
    {t='tchar',     k='szInsurePass',        s=G_NetLength.LEN_PASSWORD,},        -- 银行密码
    {t='byte',      k='cbCurrencyType',      },                         -- 货币类型: 1金币，2TC币
    {t='score',     k='llScore',             },                         -- 货币值
    {t='dword',     k='dwClientAddr',        },                         -- 连接地址
    {t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器码
}
--取出游戏币返回(与存入游戏币结构相同)  CMD: 1313
cmd_bank.CMD_MB_UserTakeScoreExResult = cmd_bank.CMD_MB_UserSaveScoreExResult
--转帐游戏币  CMD: 1314
cmd_bank.CMD_MB_UserTransferScoreEx = {
    {t='dword',     k='dwUserID',            },                         -- 用户ID
    {t='tchar',     k='szInsurePass',        s=G_NetLength.LEN_PASSWORD,},        -- 银行密码
    {t='byte',      k='cbCurrencyType',      },                         -- 货币类型: 1金币，2TC币
    {t='score',     k='llScore',             },                         -- 货币值
    {t='dword',     k='dwTargetGameID',      },                         -- 接收人游戏ID
    {t='dword',     k='dwClientAddr',        },                         -- 连接地址
    {t='tchar',     k='szMachineID',         s=G_NetLength.LEN_MACHINE_ID,},      -- 机器码
}
--转帐游戏币返回(与存入游戏币结构相同)  CMD: 1315
cmd_bank.CMD_MB_UserTransferScoreExResult = cmd_bank.CMD_MB_UserSaveScoreExResult
--查询转账记录  CMD: 1316
cmd_bank.CMD_MB_QueryTransferRecordsEx = {
    {t='dword',     k='dwUserID',            },                         -- 用户ID
    {t='tchar',     k='szDynamicPass',       s=G_NetLength.LEN_PASSWORD,},        -- 动态密码
    {t='byte',      k='cbCurrencyType',      },                         -- 货币类型: 1金币 2TC币
    {t='byte',      k='cbTransferType',      },                         -- 转账类型: 1转入 2转出
    {t='dword',     k='dwPageSize',          },                         -- 每页容量
    {t='dword',     k='dwPageIndex',         },                         -- 页号:从1开始
}

cmd_bank.tagTransferRecordInfo = {
    {t='score',     k='tmCollectDate',         },                         -- 转账货币值
    {t='score',     k='llSwapScore',         },                         -- 转账货币值
    {t='dword',     k='dwSrcUserID',         },                         -- 用户ID
    {t='dword',     k='dwSrcGameID',         },                         -- 游戏ID
    {t='tchar',     k='szSrcNickName',       s=G_NetLength.LEN_NICKNAME,},        -- 昵称
    {t='dword',     k='dwSrcFaceID',         },                         -- 头像
    {t='dword',     k='dwDstUserID',         },                         -- 用户ID
    {t='dword',     k='dwDstGameID',         },                         -- 游戏ID
    {t='tchar',     k='szDstNickName',       s=G_NetLength.LEN_NICKNAME,},        -- 昵称
    {t='dword',     k='dwDstFaceID',         },                         -- 头像
}
--查询转账记录返回  CMD: 1317
cmd_bank.CMD_MB_QueryTransferRecordsExResult = {
    {t='byte',      k='cbCurrencyType',      },                         -- 入参原样退回
    {t='byte',      k='cbTransferType',      },                         -- 入参原样退回
    {t='dword',     k='dwPageSize',          },                         -- 入参原样退回 
    {t='dword',     k='dwPageIndex',         },                         -- 入参原样退回 
    {t='dword',     k='dwRecordCount',       },                         -- 总记录数
    {t='dword',     k='dwPageCount',         },                         -- 总页数
    {t='dword',     k='dwCount',             },                         -- 标识下面数组的长度
	{t="table", k = "lsItems", d = cmd_bank.tagTransferRecordInfo}
}

-- --增送转让货币
-- -- TransferScore:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_TRANSFER_SCORE)
-- cmd_bank.CMD_MB_TransferScore = {
--     {t='dword',     k='dwUserID',            },                                     -- 用户ID
--     {t='score',     k='llSwapScore',         },                                     -- 转账货币值
-- 	{t='tchar',     k='szBankPassword',       s= G_NetLength.LEN_PASSWORD,},        -- 银行密码
-- 	{t="tchar",     k="szAccounts",           s= G_NetLength.LEN_ACCOUNTS},         --目标用户
--     {t='tchar',     k='szMachineID',          s= G_NetLength.LEN_MACHINE_ID,},      -- 机器序列
-- 	{t="tchar",     k="sztemp",               s= G_NetLength.LEN_ACCOUNTS},         --未知字段
-- }

return cmd_bank
  
  