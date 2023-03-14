
local C = {}

--鱼索引
C.Fish_01= 1-1  --
C.Fish_02= 2-1  --
C.Fish_03= 3-1  --
C.Fish_04= 4-1  --
C.Fish_05= 5-1  --
C.Fish_06= 6-1  --
C.Fish_07= 7-1  --
C.Fish_08= 8-1  --
C.Fish_09= 9-1  --
C.Fish_10= 10-1  --
C.Fish_11= 11-1  --
C.Fish_12= 12-1  --
C.Fish_13= 13-1  --
C.Fish_14= 14-1  --
C.Fish_15= 15-1  --
C.Fish_16= 16-1  --
C.Fish_17= 17-1  --
C.Fish_18= 18-1  --
C.Fish_19= 19-1  --
C.Fish_20= 20-1  --
C.Fish_21= 21-1  --
C.Fish_22= 22-1  --
C.Fish_23= 23-1  --章鱼
C.Fish_24= 24-1  --海妖
C.Fish_25= 25-1  --船
C.Fish_26= 26-1  --玉皇大帝
C.Fish_27= 27-1  --悟空
C.Fish_28= 28-1  --佛手
C.Fish_29= 29-1  --金箍棒
C.Fish_30= 30-1  --风火轮
C.Fish_31= 31-1  --定


C.Buff_YiWangDaJin  = 1 -- 一网打尽
C.Buff_FangSheYu    = 2 -- 放射鱼
C.Buff_ShanDian     = 3 -- 闪电鱼
C.Buff_Combine      = 4 -- 组合鱼  (一箭双雕 一石三鱼, 金玉满堂)


C.Tip_Map = {
	[C.Fish_27] = "tips_wukong",
	[C.Fish_26] = "tips_yudi",
}

C.EffConfig = {
	[C.Fish_01] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=1,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_02] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=1,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_03] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=1,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_04] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=2,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_05] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=2,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_06] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=3,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_07] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=4,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_08] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=4,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_09] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=5,  coinRange=80, goldCircle=false, goldBomb=false, lockScale=1,   sharkScreen=false,},
	[C.Fish_10] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=5, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_11] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=5, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_12] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=5, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_13] = { deadScale=1, buffScale=0.5, coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_14] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_15] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_16] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_17] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_18] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_19] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=6, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_20] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_21] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_22] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=false, lockScale=0.5, sharkScreen=false,},
	[C.Fish_23] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=true,  lockScale=0.5, sharkScreen=false,},
	[C.Fish_24] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=true,  lockScale=0.5, sharkScreen=false,},
	[C.Fish_25] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=true,  lockScale=0.5, sharkScreen=false,},
	[C.Fish_26] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=true,  lockScale=0.5, sharkScreen=false,},
	[C.Fish_27] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=true,  goldBomb=true,  lockScale=0.5, sharkScreen=false,},
	[C.Fish_28] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=true,},
	[C.Fish_29] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=false, goldBomb=true,  lockScale=0.5, sharkScreen=true,},
	[C.Fish_30] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=false, goldBomb=true,  lockScale=0.5, sharkScreen=true,},
	[C.Fish_31] = { deadScale=1, buffScale=1,   coin="eff_jinbi", coinCount=7, coinRange=80, goldCircle=false, goldBomb=false, lockScale=0.5, sharkScreen=false,},
}

C.CombieFish = {
    [2] = {cc.p(0,30), cc.p(0,-30),},
    [3] = {cc.p(40,0), cc.p(-40,-40),cc.p(-40,40)},
    [5] = {cc.p(0,0), cc.p(60,60), cc.p(-60,60),cc.p(-60,-60), cc.p(60,-60),},
}

C.BombFish = {
	[C.Fish_29] = 750/4,
	[C.Fish_30] = 750/2,
}

C.IsBomb = {
	[C.Fish_28] = true,
	[C.Fish_29] = true,
	[C.Fish_30] = true,
}

C.BuffFishConfig = {
	[C.Buff_YiWangDaJin] = {lockScale=0.6,},
	[C.Buff_FangSheYu] = {lockScale=0.6,},
	[C.Buff_ShanDian] = {lockScale=0.6,},
	[C.Buff_Combine] = {lockScale=0.6,},
}

return C