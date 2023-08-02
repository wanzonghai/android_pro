
local cmd  = {}

--游戏版本
cmd.VERSION       = appdf.VersionValue(6,7,0,1)         --(6,6,0,3)
--游戏标识
cmd.KIND_ID       = 520         --511
--游戏人数
cmd.GAME_PLAYER       = 4         --8
--房间名长度
cmd.SERVER_LEN      = 32

cmd.INT_MAX = 2147483647

cmd.Event_LoadingFish  = "Event_LoadingFinish"
cmd.Event_FishCreate   = "Event_FishCreate"
cmd.SCREENWIDTH = 1152.0
cmd.SCREENHEIGTH = 720.0
cmd.FISHMOVEBILI = 0.8

--音效
cmd.Load_Back      = "sound_res/LOAD_BACK.mp3"
cmd.Music_Back_1   = "sound_res/MUSIC_BACK_01.mp3"
cmd.Music_Back_2   = "sound_res/MUSIC_BACK_02.mp3"
cmd.Music_Back_3   = "sound_res/MUSIC_BACK_03.mp3"
cmd.Change_Scene   = "sound_res/CHANGE_SCENE.mp3"
cmd.CoinAnimation  = "sound_res/CoinAnimation.mp3"
cmd.Coinfly        = "sound_res/coinfly.mp3"
cmd.Special_Shoot  = "sound_res/special_shoot.mp3"
cmd.Combo          = "sound_res/combo.mp3"

cmd.CoinLightMove  = "sound_res/CoinLightMove.mp3"
cmd.Prop_armour_piercing = "sound_res/PROP_ARMOUR_PIERCING.mp3"

cmd.SWITCHING_RUN      = "sound_res/SWITCHING_RUN.mp3"
cmd.bingo      = "sound_res/bingo.mp3"

local enumCannonType = 
{

  "Normal_Cannon", --正常炮
  "Bignet_Cannon",--网变大
  "Special_Cannon",--加速炮
  "Laser_Cannon",--激光炮
  "Laser_Shooting"--激光发射中
}
cmd.CannonType = g_ExternalFun.declarEnumWithTable(0,enumCannonType)

-----------------------------------------------------------------------------------------------
--服务器命令结构

	--cmd.SUB_S_SYNCHRONOUS 	= 101					-- 同步信息101   
cmd.SUB_S_GAME_CONFIG	   = 100					         -- 初始化数据
cmd.SUB_S_TRACE_POINT    = 101                   --鱼62
cmd.SUB_S_MULTIPLE		   = 102                   --上分消息
cmd.SUB_S_FIRE		       = 103					         -- 开火63
cmd.SUB_S_NOFISH		     = 104					         -- 没打中鱼，miss,协议已不需要
cmd.SUB_S_CATCH_FISH  	 = 105					         -- 捕获鱼103
cmd.SUB_S_LOCK_SCENE     = 106                   --定屏
cmd.SUB_S_LOCK_TIMEOUT   = 107                   -- 锁定时间到，没有数据
cmd.SUB_S_CATCH_SWEEP_FISH          = 108       --抓到BOSS和炸弹时
cmd.SUB_S_CATCH_SWEEP_FISH_RESULT   = 109       --抓到BOSOS和炸弹的结果
cmd.SUB_S_EXCHANGE_SCENE = 111					         -- 转换场景105
cmd.SUB_S_SCENE_END      = 112                   --场景结束
cmd.SUB_S_NoFire         = 113                   --不允许开枪
cmd.SUB_S_CAN_FIRE		 = 114                   --// 可以开火
cmd.SUB_S_FIRE_ERR		 = 115                   --// CLINET NO 场景结束 
cmd.SUB_S_TimeUp         = 116                   --60s时间到了被T
cmd.SUB_S_SWITCH_SCENE_PRESAGE = 117              --鱼潮要来了
cmd.SUB_S_USER_SCORE_UPDATE = 118                --金币更新
cmd.SUB_S_Zongfen        = 131                   --更新总分

cmd.SUB_S_FISH_GROUP     = 120 
cmd.SUB_S_PLAYER_LOCK_FISH      = 121

cmd.SUB_S_EXCHANGE_GAME_SCENEING = 122   --场景中发送

-----------------------------------------------------------------------------------------------

--顶点
cmd.CDoulbePoint = 
{
	{k="x",t="double"},
	{k="y",t="double"}
}

cmd.ShortPoint = 
{

	{k="x",t="short"},
	{k="y",t="short"}
}

cmd.tagBezierPoint = 
{
 {k="BeginPoint",t="table",d=cmd.CDoulbePoint},
 {k="EndPoint",t="table",d=cmd.CDoulbePoint},
 {k="KeyOne",t="table",d=cmd.CDoulbePoint},
 {k="KeyTwo",t="table",d=cmd.CDoulbePoint},
 {k="Time",t="dword"}

}

--鱼创建
cmd.CMD_S_FishCreate = 
{
  {k="nFishKey",t="int"},
  {k="nFishType",t="int"},
  {k="nBezierCount",t="int"},
  {k="m_fudaifishtype",t="int"},
  {k="m_BuildTime",t="int"},
  {k="unCreateTime",t="int"},
  {k="nFishState",t="int"}

}

--dyj1(Fc++)
cmd.CMD_S_FishMissed =  --未用到此协议
{
    {k="chair_id",t="word"},
    {k="bullet_mul",t="int"},
    {k="bullet_id", t="dword"}
}
cmd.FPoint = 
{
    {k="x",t="float"},
    {k="y",t="float"}
}

cmd.CMD_S_FishTrace = 
{
  {k="cmd_version",t="byte"},
  {k="fish_kind",t="int"},
  {k="fish_id",t="int"},
  {k="trace_type",t="int"},
  {k="fish_buff",t="byte"},--1一网打尽 2--放射圈鱼 3--闪电
}

cmd.CMD_S_SwitchScene =
{
  {k="scene_kind",t="int"},
  {k="fish_count",t="int"},
  {k="fish_kind",t="int",l={300}},
  {k="fish_id",t="int",l={300}}
}

cmd.CMD_S_SwitchGameSceneing =
{
  {k="scene_kind",t="int"},
  {k="fish_count",t="int"},
  {k="fish_kind",t="int",l={300}},
  {k="fish_id",t="int",l={300}},
  {k="delay_time",t="dword"}
}

-- cmd.SUB_S_FISH_GROUP = 108-- //鱼群

-- CMD_S_FishGroup
-- FishGroupItem
-- FishGroupItem
-- ...N个
-- FishGroupItem

cmd.FishGroupItem = {
  {k="fish_kind", t="dword"}, -- DWORD fish_kind;
  {k="fish_id", t="int"}, -- int fish_id;
  {k="fish_random", t="byte"},-- BYTE fish_random; //[1,100] 群状鱼群使用，调整路线
  {k="ref_fish_id", t="int"},-- int ref_fish_id; //只在绑定鱼群时生效， 指向主鱼
  {k="type", t="byte"},-- BYTE type; //只在绑定鱼群时生效， 1--主鱼
};

cmd.CMD_S_FishGroup = {
  {k="path_id", t="byte"},--= BYTE path_id;
  {k="group_type", t="byte"},-- BYTE group_type; //1-线性鱼群 2-群状鱼群 3-绑定鱼群, 4-- 放射圈鱼群
  {k="fish_item_num",t="dword"},--后面n个 FishGroupItem
};



--鱼创建完成，未用到此协议
cmd.CMD_S_FishFinish = 
{
	{k="nOffSetTime",t="dword"}
}

cmd.Fish_Catch_Item = {
  {k="fish_id", t="int"},
  {k="fish_kind", t="dword"},
  {k="fish_score", t="score"},
};

--捕获鱼
cmd.CMD_S_CatchFish = 
{
    {k="wChairID",t="word"},         --玩家椅子
    {k="bullet_ion",t="bool"},         --变身子弹
    {k="fish_score", t="score"},--总分
    {k="total_fish_score",t="score"},
    {k="fish_caijin_score", t="score"},--
    {k="catch_fish_num",t="dword"},--后面n个 Fish_Catch_Item
    {k="bullet_id", t="dword"},
}

--抓到BOSS和炸弹时
cmd.CMD_S_CatchSweepFish = 
{
    {k="wChairID",t="word"},        
    {k="dwFishID",t="int"},         
    {k="bullet_mul",t="int"},     
    {k="fish_count",t="int"},
    {k="fish_kind",t="int",l = {5}}     
}

--抓到BOSOS和炸弹的结果
cmd.CMD_S_CatchSweepFishResult = 
{
    {k="wChairID",t="word"},    
    {k="dwFishID",t="int"},         
    {k="fish_score",t="score"},    
    {k="catch_fish_count",t="int"},         
    {k="catch_fish_id",t="int",l = {300}}, 
}

-- --开火
-- cmd.CMD_S_Fire = 
-- {

--   {k="wChairID",t="int"},						-- 玩家位置
--   {k="fAngle",t="float"},                       -- 角度
--   {k="nBulletKey",t="int"},						-- 子弹关键值
--   {k="byShootCount",t="bool"},                  --
--   {k="nBulletScore",t="int"},					-- 玩家分数
--   {k="dwZidanID",t="int"},
--   {k="PowerPer",t="float"},
--   {k="sBullet",t="score"}                       --子弹花费
-- }
--dyj1(FC++)
cmd.CMD_S_UserFire = 
{
  {k="bullet_kind",t="int"},
  {k="bullet_id",t="int"},
  {k="chair_id",t="word"},
  {k="proxy_chairid",t="word"},   -- 机器人代理椅子号
  {k="angle",t="float"},
  {k="bullet_mulriple",t="int"},             --炮台倍率
  {k="bullet_speed",t="int"},             --速度
  {k="lock_fishid",t="int"},
  {k="total_fish_score",t="score"},
  {k="is_lock",t="bool"}
}
--dyj2

--dyj1(FC++)
cmd.CMD_S_ExchangeFishScore = 
{
  {k="chair_id",t="word"},
  {k="swap_fish_score",t="score"},       --上分间隔
  {k="exchange_fish_score",t="score"}
}
--dyj2
cmd.CMD_S_BulletLimitCount = 
{
    {k="bullet_limit_count",t="int"}    --子弹限制数
}
--dyj1(FC++)
cmd.CMD_S_GameConfig = 
{
  {k="exchange_bullet_count",t="int"},                -- 单次上分分数
  {k="EmptyFireCount",t="int"},   --允许的最大炮数

}
--dyj2

--补给信息
--[[cmd.CMD_S_Supply = 
{

  {k="wChairID",t="word"},
  {k="lSupplyCount",t="score"},
  {k="nSupplyType",t="int"}
}

cmd.CMD_S_Multiple = 
{

  {k="wChairID",t="int"},
  {k="nMultipleIndex",t="int"}
}

cmd.CMD_S_BeginLaser = 
{
  {k="wChairID",t="word"},
  {k="ptPos",t="table",d=cmd.ShortPoint}
}

--激光
cmd.CMD_S_Laser = 
{
	{k="wChairID",t="int"},
    {k="IsAndroid",t="bool"},
    {k="fAngle",t="float"}
}

--转换场景
cmd.CMD_S_ChangeSecene =
{

    {k="cbBackIndex",t="int"},
    {k="RmoveID",t="int"}

}

cmd.CMD_S_StayFish = 
{


 {k="nFishKey",t="int"},
 {k="nStayStart",t="int"},
 {k="nStayTime",t="int"}


}
cmd.CMD_S_SupplyTip = 
{

  {k="wChairID",t="word"}
}

cmd.CMD_S_AwardTip = 
{

  {k="wTableID",t="word"},
  {k="wChairID",t="word"},
  {k="szPlayName",t="string",s=32},
  {k="nFishType",t="byte"},
  {k="nFishMultiple",t="int"},
  {k="lFishScore",t="score"},
  {k="nScoreType",t="int"}
}

cmd.CMD_S_UpdateGame = 
{
  {k="nMultipleValue",t="int",l={cmd.Multiple_Max}},
  {k="nFishMultiple",t="int",l={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}},
  {k="nBulletVelocity",t="int"},
  {k="nBulletCoolingTime",t="int"},
  {k="nMaxTipCount",t="int"},-- 消息限制
}
]]
--银行
cmd.CMD_S_BankTake = 
{
  {k="wChairID",t="word"},
  {k="lPlayScore",t="score"},
}

--场景信息
cmd.GameScene = 
{
{k="game_version",t="dword"},
{k="fish_score",t="score",l={cmd.GAME_PLAYER}},
{k="MinShoot",t="int"},
{k="MaxShoot",t="int"},
{k="isYuZhen",t="bool"},
{k="bullet_index",t="int"},
{k="is_lock_scene",t="bool"},
{k="lock_over_time",t="dword"},
{k="is_no_fire",t="bool"},
}

cmd.CMD_S_UpdateAllScore =
{
    {k="wChairID",t="word"},         --玩家椅子
    {k="dwFishID",t="int"},          --鱼群标识
    {k="FishKind",t="int"},          --鱼群种类
    {k="bullet_ion",t="bool"},       --变身子弹
    {k="lFishScore",t="score"},      --鱼群得分
    {k="fish_caijin_score",t="score"}
}


cmd.FishScore={2,2,3,4,5,6,7,8,9,10,12,15,18,20,25,30,35,40,120,320,40,20,150,0,180,100}

--dyj1(Fc++)
cmd.FishSpeed = {5,5,5,5,5,5,5,5,5,5,4,4,4,4,4,3,3,3,2,1,2,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5}
cmd.FishCount = { 10, 10, 8, 8, 7, 6, 6, 6, 6, 6, 4, 4, 4, 3, 3, 3, 2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
--dyj2

cmd.CMD_S_UpdateFishScore =
{
  {k="nFishKey",t="int"},
  {k="nFishScore",t="int"},
}
----------------------------------------------------------------------------------------------
--客户端命令结构
 
cmd.SUB_C_BEGIN_LASER= 104              -- 准备激光
cmd.SUB_C_LASER      = 68               -- 激光105
cmd.SUB_C_SPEECH     = 106              -- 语音消息
cmd.SUB_C_MULTIPLE   = 64               -- 倍数消息
cmd.SUB_C_CONTROL    = 108              -- 控制消息
cmd.SUB_C_LOCKFISH   = 65               --锁定鱼
cmd.SUB_C_ADDORDOWNSCORE = 101          --上下分
cmd.SUB_C_FIRE       = 102              --开火62
cmd.SUB_C_CATCH_FISH = 103              --捕鱼信息101
cmd.SUB_C_CATCH_SWEEP_FISH  = 104               --鱼王全死
cmd.SUB_C_USER_ALREADY      = 105       --// 用户已经准备好了
cmd.SUB_C_FORBID_FISH = 152             --控制鱼数
cmd.SUB_C_PLAYER_LOCK_FISH   = 172

return cmd