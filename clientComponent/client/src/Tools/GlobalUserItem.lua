
GlobalUserItem = GlobalUserItem or {}

--原始游戏列表
GlobalUserItem.m_tabOriginGameList = {}     
GlobalUserItem.bEnableRoomCard 							= false 	-- 激活房卡功能
--重置数据
function GlobalUserItem.reSetData()
	GlobalUserItem.bVistor 									= nil		
	GlobalUserItem.bWeChat									= false
	GlobalUserItem.dwGameID									= 0
	GlobalUserItem.dwUserID									= 0			
     
	GlobalUserItem.dwExperience								= 0			
	GlobalUserItem.dwLoveLiness								= 0		

	GlobalUserItem.szAccount								= ""
	GlobalUserItem.szPassword								= ""	
	GlobalUserItem.szMachine								= ""
	GlobalUserItem.szMobilePhone							= ""
	GlobalUserItem.szRoomPasswd								= ""
					
	GlobalUserItem.szNickName								= ""						
	GlobalUserItem.szInsurePass								= ""						
	GlobalUserItem.szDynamicPass							= ""
	-- 个人信息附加包
	GlobalUserItem.szSign									= "此人很懒，没有签名"	
	GlobalUserItem.szSpreaderAccount 						= "" 		-- 推广员
	GlobalUserItem.szQQNumber 								= "" 		-- qq号码
	GlobalUserItem.szEmailAddress 							= "" 		-- 邮箱地址
	GlobalUserItem.szSeatPhone 								= "" 		-- 座机
	GlobalUserItem.szMobilePhone 							= "" 		-- 手机
	GlobalUserItem.szTrueName 								= "" 		-- 真实姓名
	GlobalUserItem.szAddress 								= "" 		-- 联系地址
	GlobalUserItem.szPassportID 							= "" 		-- 身份ID
	-- 个人信息附加包

	GlobalUserItem.lUserScore								= 0						--用户金币
	GlobalUserItem.lTCCoin								    = 0						--用户元宝 TC 币
	GlobalUserItem.lUserInsure								= 0						--银行存款
	GlobalUserItem.lTCCoinInsure							= 0.00 					--TC 银行存款
	GlobalUserItem.cbInsureEnabled							= 0	
	GlobalUserItem.nLargeTrumpetCount						= 0						--大喇叭数量	

	GlobalUserItem.cbGender									= 0							
	GlobalUserItem.cbMemberOrder							= 0
	GlobalUserItem.MemberOverDate							= 0		
	GlobalUserItem.MemberList								= {}			

	GlobalUserItem.wFaceID									= 0							
	GlobalUserItem.dwCustomID								= 0	

	GlobalUserItem.dwStationID								= 0	

	-- GlobalUserItem.nCurGameKind								= 122
	GlobalUserItem.szCurGameName							= ""
	GlobalUserItem.roomlist 								= {}
	GlobalUserItem.RoomList_p                               = {}    --kind*100 + serverKind*10 + sortID = key  这个列表的key是组合出来的唯一房间标识
	GlobalUserItem.roomIpAddresslist 						= {}  --房间ip地址
	GlobalUserItem.RecommendList							= {}	--推荐玩法列表
	GlobalUserItem.tasklist 								= {}
	GlobalUserItem.wTaskCount 								= 0

    GlobalUserItem.nCurRoomServerPort                        = -1
	-- GlobalUserItem.nCurRoomIndex 							= -1

	GlobalUserItem.nGameResType								= 0

	GlobalUserItem.bVoiceAble								= true
	GlobalUserItem.bSoundAble								= true

	GlobalUserItem.nSound									= 100
	GlobalUserItem.nMusic									= 100
	GlobalUserItem.bShake									= true

	GlobalUserItem.szHelp									= nil

	-- GlobalUserItem.bAutoLogon								= false
	-- GlobalUserItem.bSavePassword							= false
	-- GlobalUserItem.bHasLogon								= false  --已经登录过
	-- GlobalUserItem.bVisitor									= false
    -- GlobalUserItem.bLogonType                               = 1   --1，账号登陆，2，游客登陆，3第三方平台登陆
    -- GlobalUserItem.szWxAccessToken                          = ""  --微信登录access_token
    -- GlobalUserItem.szWxOpenID                               = ""  --微信openID
	-- GlobalUserItem.LogonTime								= 0

	GlobalUserItem.wCurrLevelID 							= 0
	GlobalUserItem.dwExperience 							= 0
	GlobalUserItem.dwUpgradeExperience 						= 0
	GlobalUserItem.lUpgradeRewardGold 						= 0
	GlobalUserItem.lUpgradeRewardIngot						= 0

	GlobalUserItem.wSeriesDate								= 0 		--连续日期
	GlobalUserItem.bTodayChecked							= false 	--今日签到
	GlobalUserItem.lRewardGold 								= {0,0,0,0,0,0,0}		--金币数目
	GlobalUserItem.buyItem									= nil
	GlobalUserItem.useItem 									= nil

	GlobalUserItem.szThirdPartyUrl							= ""		--第三方头像url
	GlobalUserItem.bThirdPartyLogin							= false
	GlobalUserItem.thirdPartyData 							= {}		--第三方登陆数据	
	GlobalUserItem.m_tabEnterGame							= nil 		--保存进入游戏的数据
    GlobalUserItem.m_gamePageIndex                          = nil
	GlobalUserItem.dwServerRule								= 0			--房间规则
	GlobalUserItem.bEnterGame								= false 	--进入游戏
	GlobalUserItem.bIsAgentAccount							= false 	--是否是代理商帐号	

	GlobalUserItem.bQueryCheckInData						= false

	GlobalUserItem.nTableFreeCount							= 0			--转盘免费次数
	GlobalUserItem.nShareSend								= 0			--每日首充赠送
    GlobalUserItem.bIsCharge                                 = false     --是否允许花钱摇奖

	GlobalUserItem.bJftPay									= false
	GlobalUserItem.szSpreaderURL							= nil 		--普通分享链接
	GlobalUserItem.szWXSpreaderURL 							= nil 		--微信分享链接

	GlobalUserItem.tabShopCache								= {} 		--商店信息缓存
	GlobalUserItem.tabRankCache								= {} 		--排行信息缓存
    GlobalUserItem.lastOpenTime                             = 0
	GlobalUserItem.bFilterTask								= false 	--是否过滤任务 (只显示单个游戏任务)

	GlobalUserItem.bPrivateRoom 							= false 	-- 私人房

	GlobalUserItem.lRoomCard 								= 0			-- 房卡数量
	GlobalUserItem.dwLockServerKindID 					    = 0			-- 锁定房间，这里是具体房间 serverKind*10 + sortID
	GlobalUserItem.dwLockKindID 							= 0 		-- 锁定游戏
	GlobalUserItem.bWaitQuit 								= false 	-- 等待退出
	GlobalUserItem.bAutoConnect 							= true 		-- 是否自动断线重连(游戏切换到主页再切换回)

	GlobalUserItem.cbLockMachine 							= 0 		-- 是否锁定设备
	GlobalUserItem.szIpAdress 								= "" 		-- ip地址
	GlobalUserItem.tabCoordinate 							= {lo = 360.0, la = 360.0} 		-- 坐标
	GlobalUserItem.bUpdateCoordinate 						= false 	-- 是否更新坐标
	GlobalUserItem.tabDayTaskCache 							= {} 		-- 每日必做列表
	GlobalUserItem.nInviteSend 								= 0			-- 邀请奖励
	GlobalUserItem.bEnableCheckIn 							= false 	-- 激活签到
	GlobalUserItem.bEnableTask 								= false 	-- 激活任务
	GlobalUserItem.bEnableEveryDay							= false 	-- 激活每日任务开关

	GlobalUserItem.szCopyRoomId 							= "" 		-- 复制房间id 	
	GlobalUserItem.dwAgentID                               = 0         -- 公会ID

	GlobalUserItem.expressionCost 							= {} 		--表情价格配置列表


	--VIP信息
	-- GlobalUserItem.VIPEnable   								= false 	--是否允许VIP
	GlobalUserItem.VIPLevel									= 0			--VIP等级
	GlobalUserItem.VIPInfo									= {}		--VIP详情
end

--读取配置
function GlobalUserItem.LoadData()
	--声音设置
	GlobalUserItem.bVoiceAble = cc.UserDefault:getInstance():getBoolForKey("vocieable",true)
	GlobalUserItem.bSoundAble = cc.UserDefault:getInstance():getBoolForKey("soundable", true)
    GlobalUserItem.setSoundAble(GlobalUserItem.bSoundAble)
	--音量设置
	GlobalUserItem.nSound = cc.UserDefault:getInstance():getIntegerForKey("soundvalue",100)
	GlobalUserItem.nMusic = cc.UserDefault:getInstance():getIntegerForKey("musicvalue",100)
	--震动设置
	GlobalUserItem.bShake = cc.UserDefault:getInstance():getBoolForKey("shakeable",true)	

	if GlobalUserItem.bVoiceAble then
		AudioEngine.setMusicVolume(GlobalUserItem.nMusic/100.0)		
	else
		AudioEngine.setMusicVolume(0)
	end
	
	if GlobalUserItem.bSoundAble then
		AudioEngine.setEffectsVolume(GlobalUserItem.nSound/100.00) 
	else
		AudioEngine.setEffectsVolume(0) 
	end	

	--自动登录
	-- GlobalUserItem.bAutoLogon = cc.UserDefault:getInstance():getBoolForKey("autologon",false)

	-- --账号密码
	-- local sp = ""

	-- local tmpInfo = readByDecrypt(sp.."user_gameconfig.plist","code_1")
	-- tdump(tmpInfo, "tmpInfo is ", 10)
	-- --检验
	-- if tmpInfo ~= nil and #tmpInfo >32 then
	-- 	local md5Test = string.sub(tmpInfo,1,32)
	-- 	tmpInfo = string.sub(tmpInfo,33,#tmpInfo)
	-- 	if md5Test ~= md5(tmpInfo) then
	-- 		print("test:"..md5Test.."#"..tmpInfo)
	-- 		tmpInfo = nil
	-- 	end
	-- else
	-- 	tmpInfo = nil
	-- end

	-- if tmpInfo ~= nil then
	-- 	GlobalUserItem.szAccount = tmpInfo
	-- 	tmpInfo = readByDecrypt(sp.."user_gameconfig.plist","code_2")
	-- 	--检验
	-- 	if tmpInfo ~= nil and #tmpInfo >32 then
	-- 		local md5Test = string.sub(tmpInfo,1,32)
	-- 		tmpInfo = string.sub(tmpInfo,33,#tmpInfo)
	-- 		if md5Test ~= md5(tmpInfo) then
	-- 			print("test:"..md5Test.."#"..tmpInfo)
	-- 			tmpInfo = nil
	-- 		end
	-- 	else
	-- 		tmpInfo = nil
	-- 	end
	-- 	if tmpInfo ~= nil then
	-- 		GlobalUserItem.szPassword = tmpInfo
	-- 		GlobalUserItem.bSavePassword = true
	-- 	else
	-- 		GlobalUserItem.szPassword = ""
	-- 		GlobalUserItem.bSavePassword = false
	-- 	end
	-- else
	-- 	GlobalUserItem.szAccount = ""
	-- 	GlobalUserItem.szPassword = ""
	-- 	-- GlobalUserItem.bAutoLogon = false
	-- 	GlobalUserItem.bSavePassword = false
	-- end
	GlobalUserItem.wCurrLevelID 							= 0
	GlobalUserItem.dwExperience 							= 0
	GlobalUserItem.dwUpgradeExperience 						= 0
	GlobalUserItem.lUpgradeRewardGold 						= 0
	GlobalUserItem.lUpgradeRewardIngot						= 0
	
	--加载本地化数据
	GlobalUserItem.GetLocalization()
end

GlobalUserItem.reSetData()


function GlobalUserItem.setShakeAble(able)
	GlobalUserItem.bShake = able
	cc.UserDefault:getInstance():setBoolForKey("shakeable",GlobalUserItem.bShake)
end

function GlobalUserItem.setSoundAble(able)
	GlobalUserItem.bSoundAble = able
	if true == able then
		AudioEngine.setEffectsVolume(GlobalUserItem.nSound/100.00)
        cc.FileUtils:getInstance():setEnableButtonPressSound(true)
	else
		AudioEngine.setEffectsVolume(0)
        cc.FileUtils:getInstance():setEnableButtonPressSound(false)
	end
	cc.UserDefault:getInstance():setBoolForKey("soundable",GlobalUserItem.bSoundAble)
end

function GlobalUserItem.setVoiceAble(able)
	GlobalUserItem.bVoiceAble = able
	if  GlobalUserItem.bVoiceAble == true then
		AudioEngine.setMusicVolume(GlobalUserItem.nMusic/100.0)
	else		
		AudioEngine.setMusicVolume(0)
		AudioEngine.stopMusic() -- 暂停音乐  
	end
	cc.UserDefault:getInstance():setBoolForKey("vocieable",GlobalUserItem.bVoiceAble)
end

function GlobalUserItem.setMusicVolume(music) 
	local tmp = music 
	if tmp >100 then
		tmp = 100
	elseif tmp < 0 then
		tmp = 0
	end
	AudioEngine.setMusicVolume(tmp/100.0) 
	GlobalUserItem.nMusic = tmp
	cc.UserDefault:getInstance():setIntegerForKey("musicvalue",GlobalUserItem.nMusic)
end

function GlobalUserItem.setEffectsVolume(sound) 
	local tmp = sound 
	if tmp >100 then
		tmp = 100
	elseif tmp < 0 then
		tmp = 0
	end
	AudioEngine.setEffectsVolume(tmp/100.00) 
	GlobalUserItem.nSound = tmp
	cc.UserDefault:getInstance():setIntegerForKey("soundvalue",GlobalUserItem.nSound)
end

--查询房间信息
function GlobalUserItem.GetRoomInfo(roomMark)
	-- tlog('GlobalUserItem.GetRoomInfo ', index, nKindID)
	-- local checkKind 
	-- if not nKindID then
	-- 	checkKind = GlobalUserItem.nCurGameKind
	-- else
	-- 	checkKind = tonumber(nKindID)
	-- end
	-- if not checkKind then
	-- 	print("not checkKind")
	-- 	return nil
	-- end

	-- local roomIndex = index
	-- if not roomIndex then
	-- 	 roomIndex = GlobalUserItem.nCurRoomIndex
	-- end
	-- if not roomIndex then 
	-- 	print("not roomIndex")
	-- 	return nil
	-- end
	-- if roomIndex <1 then
	-- 	print("roomIndex <1")
	-- 	return nil
	-- end
	-- -- tdump(GlobalUserItem.roomlist, "GlobalUserItem.roomlist", 10)
	-- for i = 1,#GlobalUserItem.roomlist do
	-- 	local list = GlobalUserItem.roomlist[i]
	-- 	if tonumber(list[1]) == tonumber(checkKind) then
	-- 		local listinfo = list[2]
	-- 		if not listinfo then
	-- 			print("not listinfo")
	-- 			return nil
	-- 		end
	-- 		if roomIndex > #listinfo then 
	-- 			print("roomIndex > #listinfo")
	-- 			return nil
	-- 		end
	-- 		return listinfo[roomIndex]
	-- 	end
	-- end
	if not roomMark then 
		return nil
	end
	if GlobalUserItem.RoomList_p[roomMark] then
		return GlobalUserItem.RoomList_p[roomMark]
	else
		return nil
	end
end


--获取服务器开启的游戏房间
function GlobalUserItem.GetServerRoomByGameKind(gameKind)
	if not gameKind then 
		printInfo("not kindid")
		return nil
	end
    local roomInfo = clone(GlobalUserItem.roomlist[gameKind])
	return roomInfo
	-- for i = 1,#GlobalUserItem.roomlist do
	-- 	local list = GlobalUserItem.roomlist[i]
	-- 	if tonumber(list[1]) == tonumber(gameKind) then
	-- 		local listinfo = list[2]
	-- 		if not listinfo then
	-- 			print("not listinfo")
	-- 			return nil
	-- 		end
	-- 		roomInfo = clone(listinfo)
    --         return roomInfo
	-- 	end
	-- end
end

function GlobalUserItem.getCurTypeRoomList(gameKind,serverKind)
	local roomList = GlobalUserItem.GetServerRoomByGameKind(gameKind)


end

--加载用户信息
function GlobalUserItem.onLoadData(pData)
	if pData == nil then
		print("GlobalUserItem-LoadData-null")
		return
	end
	--登录时间
	-- GlobalUserItem.LogonTime = currentTime()

	GlobalUserItem.wFaceID = pData:readword()
    if GlobalUserItem.wFaceID >10 then GlobalUserItem.wFaceID = 10 end  
	GlobalUserItem.cbGender = pData:readbyte()
	GlobalUserItem.dwCustomID = pData:readdword()
	GlobalUserItem.dwUserID = pData:readdword()
	GlobalUserItem.dwGameID = pData:readdword()
	GlobalUserItem.dwExperience = pData:readdword()
	GlobalUserItem.dwLoveLiness = GlobalUserItem:readScore(pData)--pData:readdword()
	--GlobalUserItem.szMachineID = pData:readstring(33)
    GlobalUserItem.szAccount = pData:readstring(32)
	local strName = pData:readstring(32)
    --名字截取
    GlobalUserItem.szNickName = g_ExternalFun.FormatString2FixLen(strName,120,"微软雅黑",20)
	GlobalUserItem.szDynamicPass= pData:readstring(33)
	GlobalUserItem.lUserScore = GlobalUserItem:readScore(pData)
	GlobalUserItem.lTCCoin = GlobalUserItem:readScore(pData)
	GlobalUserItem.lUserInsure= GlobalUserItem:readScore(pData)
	GlobalUserItem.lTCCoinInsure = GlobalUserItem:readScore(pData)
	GlobalUserItem.cbInsureEnabled = pData:readbyte()
	local bAgent = pData:readbyte() or 0
	GlobalUserItem.bIsAgentAccount = (bAgent == 1)   -- 1:是会长 
	GlobalUserItem.cbLockMachine = pData:readbyte()
	GlobalUserItem.lRoomCard = GlobalUserItem:readScore(pData)
	GlobalUserItem.dwLockServerKindID = pData:readdword()
	GlobalUserItem.dwLockKindID = pData:readdword()
	GlobalUserItem.roomMark = GlobalUserItem.dwLockKindID*100 + GlobalUserItem.dwLockServerKindID   

	GlobalUserItem.dwAgentID = pData:readdword()     --是否加入公会 非0值就是工会ID

	--print("lock server " .. GlobalUserItem.dwLockServerKindID)
	--print("lock kind " .. GlobalUserItem.dwLockKindID)
	-- dump(GlobalUserItem)
	local curlen = pData:getcurlen()
	local datalen = pData:getlen()

	print("*** curlen-"..curlen)
	print("*** datalen-"..datalen)

	local tmpSize 
	local tmpCmd
	while curlen<datalen do
		 tmpSize = pData:readword()
		 tmpCmd = pData:readword()
		if not tmpSize or not tmpCmd then
		 	break
		end
		if tmpCmd == G_NetLength.DTP_GP_UI_UNDER_WRITE then
			GlobalUserItem.szSign = pData:readstring(tmpSize/2)
			if not GlobalUserItem.szSign then
				GlobalUserItem.szSign = "此人很懒，没有签名"
			end
		elseif tmpCmd == G_NetLength.DTP_GP_MEMBER_INFO then
			GlobalUserItem.cbMemberOrder = pData:readbyte();
			for i=1,8 do
				print("systemtime-"..pData:readword())
			end
		elseif tmpCmd == G_NetLength.DTP_GP_UI_QQ then
			GlobalUserItem.szQQNumber = pData:readstring(tmpSize/2) or ""
			print("qq " .. GlobalUserItem.szQQNumber)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_EMAIL then
			GlobalUserItem.szEmailAddress = pData:readstring(tmpSize/2) or ""
			print("email " .. GlobalUserItem.szEmailAddress)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_SEAT_PHONE then
			GlobalUserItem.szSeatPhone = pData:readstring(tmpSize/2) or ""
			print("szSeatPhone " .. GlobalUserItem.szSeatPhone)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_MOBILE_PHONE then
			GlobalUserItem.szMobilePhone = pData:readstring(tmpSize/2) or ""
			print("szMobilePhone " .. GlobalUserItem.szMobilePhone)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_COMPELLATION then
			GlobalUserItem.szTrueName = pData:readstring(tmpSize/2) or ""
			print("szTrueName " .. GlobalUserItem.szTrueName)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_DWELLING_PLACE then
			GlobalUserItem.szAddress = pData:readstring(tmpSize/2) or ""
			print("szAddress " .. GlobalUserItem.szAddress)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_PASSPORTID then
			GlobalUserItem.szPassportID = pData:readstring(tmpSize/2) or ""
			print("szPassportID " .. GlobalUserItem.szPassportID)
		elseif tmpCmd == G_NetLength.DTP_GP_UI_SPREADER then
			GlobalUserItem.szSpreaderAccount = pData:readstring(tmpSize/2) or ""
			print("szSpreaderAccount " .. GlobalUserItem.szSpreaderAccount)
		elseif tmpCmd == 0 then
			break
		else
			for i = 1, tmpSize do
				if not pData:readbyte() then
					break
				end
			end
		end
		curlen = pData:getcurlen()
	end
	
end

function GlobalUserItem:testlog() 
	print("**************************************************")
	--dump(self, "GlobalUserItem", 6)
	print("**************************************************")
end

function GlobalUserItem:readScore(dataBuffer)
    if self._int64 == nil then
       self._int64 = Integer64.new():retain()
    end
    dataBuffer:readscore(self._int64)
    return self._int64:getvalue()
end

function GlobalUserItem:getSignature(times)
    local timevalue = times
    print("timevalue-"..timevalue)
    local timestr = ""..timevalue
    local pstr = ""..GlobalUserItem.dwUserID
    pstr = pstr..GlobalUserItem.szDynamicPass..timestr.."GAME601Nxa2as02asxPoSsvbn"
    pstr = md5(pstr)

    print("signature-"..pstr)
    return pstr
end

function GlobalUserItem:getDateNumber(datestr)
	local index,b = string.find(datestr, "%(")
	local strname = ""
	local dwnum = ""
	if index then
		dwnum = string.sub(datestr, index+1,-1)
		strname = string.sub(datestr,1,index-1)
	end

	index = string.find(dwnum, "%)")
	if index then
		dwnum = string.sub(dwnum,1,index-1)
	end
	return dwnum
end

--是否是防作弊
function GlobalUserItem.isAntiCheat()
	return (bit:_and(GlobalUserItem.dwServerRule, G_NetCmd.SR_ALLOW_AVERT_CHEAT_MODE) ~= 0)
end

--防作弊是否有效(是否进入了游戏)
function GlobalUserItem.isAntiCheatValid(userid)
	if false == GlobalUserItem.bEnterGame then
		return false
	end

	--自己排除
	if userid == GlobalUserItem.dwUserID then
		return false
	end
	return GlobalUserItem.isAntiCheat()
end

function GlobalUserItem.todayCheck(date)
	if nil == date then
		return false
	end
	local curDate = os.date("*t")
	local checkDate = os.date("*t", date)
	if curDate.year == checkDate.year and curDate.month == checkDate.month and curDate.day == checkDate.day then
		return true
	end
	return false
end

function GlobalUserItem.setTodayFirstAction(key, value)
	cc.UserDefault:getInstance():setStringForKey(key, value .. "")
	cc.UserDefault:getInstance():flush()
end

--当日首次签到
function GlobalUserItem.isFirstCheckIn()
	local everyDayCheck = cc.UserDefault:getInstance():getStringForKey(GlobalUserItem.dwUserID .. "everyDayCheck", "nil")
	--print(everyDayCheck)
	if "nil" ~= everyDayCheck then
		local n = tonumber(everyDayCheck)
		return not GlobalUserItem.todayCheck(n)
	end
	return true
end

function GlobalUserItem.setTodayCheckIn()
	if GlobalUserItem.isFirstCheckIn() then
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayCheck", os.time())
	end	
end

--当日首次充值
function GlobalUserItem.isFirstPay()
	local everyDayPay = cc.UserDefault:getInstance():getStringForKey(GlobalUserItem.dwUserID .. "everyDayPay", "nil")
	if "nil" ~= everyDayPay then
		local n = tonumber(everyDayPay)
		return not GlobalUserItem.todayCheck(n)
	end
	return true
end

function GlobalUserItem.setTodayPay()
	if GlobalUserItem.isFirstPay() then
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayPay", os.time())
	end	
end

--当日首次分享
function GlobalUserItem.isFirstShare()
	local everyDayShare = cc.UserDefault:getInstance():getStringForKey(GlobalUserItem.dwUserID .. "everyDayShare", "nil")
	if "nil" ~= everyDayShare then
		local n = tonumber(everyDayShare)
		return not GlobalUserItem.todayCheck(n)
	end
	return true
end

function GlobalUserItem.setTodayShare()
	if GlobalUserItem.isFirstShare() then
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayShare", os.time())
	end	
end

--当日首次转盘
function GlobalUserItem.isFirstTable()
	local everyDayTable = cc.UserDefault:getInstance():getStringForKey(GlobalUserItem.dwUserID .. "everyDayTable", "nil")
	if "nil" ~= everyDayTable then
		local n = tonumber(everyDayTable)
		return not GlobalUserItem.todayCheck(n)
	end
	return true
end

function GlobalUserItem.setTodayTable()
	if GlobalUserItem.isFirstTable() then
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayTable", os.time())
	end	
end

-- 当日首页广告
function GlobalUserItem.isShowAdNotice()
	local everyDayAdNotice = cc.UserDefault:getInstance():getStringForKey(GlobalUserItem.dwUserID .. "everyDayNoAdNotice", "nil")
	if "nil" ~= everyDayAdNotice then
		local n = tonumber(everyDayAdNotice)
		return not GlobalUserItem.todayCheck(n)
	end
	return true
end

function GlobalUserItem.setTodayNoAdNotice( noAds )
	if noAds then
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayNoAdNotice", os.time())	
	else
		GlobalUserItem.setTodayFirstAction(GlobalUserItem.dwUserID .. "everyDayNoAdNotice", "nil")
	end
end

--判断是否是代理商帐号
function GlobalUserItem.isAgentAccount(nottip)
	nottip = nottip or false
	if GlobalUserItem.bIsAgentAccount then
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene and not nottip then
			-- showToast(runScene, "您是代理商帐号，无法操作！", 2)
		end
		return true
	end
	return false
end

--设置是否绑定账号
function GlobalUserItem.setBindingAccount()
	cc.UserDefault:getInstance():setBoolForKey("isBingdingAccount", true)
end

--获取是否绑定账号
function GlobalUserItem.getBindingAccount()
	return cc.UserDefault:getInstance():getBoolForKey("isBingdingAccount", false)
end

--判断是否能修改信息
function GlobalUserItem.notEditAble(nottip)
	return false
end

-- 无定位数据
function GlobalUserItem.noCoordinateData()
	if nil == GlobalUserItem.tabCoordinate 
		or nil == GlobalUserItem.tabCoordinate.la 
		or 360.0 == GlobalUserItem.tabCoordinate.la
		or nil == GlobalUserItem.tabCoordinate.lo
		or 360.0 == GlobalUserItem.tabCoordinate.lo then
		return true
	end
	return false
end

--加载登录信息
function GlobalUserItem.GetLocalization()
	GlobalUserItem.LoginType = cc.UserDefault:getInstance():getIntegerForKey("LoginType",-1)
	GlobalUserItem.LoginData = {}
	if GlobalUserItem.LoginType == 2 or GlobalUserItem.LoginType == 3 then
		GlobalUserItem.LoginData.uniqueId = cc.UserDefault:getInstance():getStringForKey("LoginDataUniqueID","")
		GlobalUserItem.LoginData.gender = cc.UserDefault:getInstance():getIntegerForKey("LoginDataGender",0)
		GlobalUserItem.LoginData.name = cc.UserDefault:getInstance():getStringForKey("LoginDataName","")
		GlobalUserItem.LoginData.token = cc.UserDefault:getInstance():getStringForKey("LoginDataToken","")
		GlobalUserItem.LoginData.email = cc.UserDefault:getInstance():getStringForKey("LoginDataEmail","")
		GlobalUserItem.LoginData.headUrl = cc.UserDefault:getInstance():getStringForKey("LoginDataHeadUrl","")
	end
end

--本地化登录信息
function GlobalUserItem.SetLocalization(args)
	if args then
		cc.UserDefault:getInstance():setIntegerForKey("LoginType",args[1] or -1)		
		cc.UserDefault:getInstance():setStringForKey("LoginDataUniqueID",args[2] or "")
		cc.UserDefault:getInstance():setIntegerForKey("LoginDataGender",args[3] or 0)
		cc.UserDefault:getInstance():setStringForKey("LoginDataToken",args[4] or "")
		cc.UserDefault:getInstance():setStringForKey("LoginDataName",args[5] or "")
		cc.UserDefault:getInstance():setStringForKey("LoginDataEmail",args[6] or "")
		cc.UserDefault:getInstance():setStringForKey("LoginDataHeadUrl",args[7] or "")		
		cc.UserDefault:getInstance():flush()
	else
		cc.UserDefault:getInstance():setIntegerForKey("LoginType",-1)		
		cc.UserDefault:getInstance():setStringForKey("LoginDataUniqueID","")
		cc.UserDefault:getInstance():setIntegerForKey("LoginDataGender",0)
		cc.UserDefault:getInstance():setStringForKey("LoginDataToken","")
		cc.UserDefault:getInstance():setStringForKey("LoginDataName","")
		cc.UserDefault:getInstance():setStringForKey("LoginDataEmail","")
		cc.UserDefault:getInstance():setStringForKey("LoginDataHeadUrl","")		
		cc.UserDefault:getInstance():flush()
	end
end