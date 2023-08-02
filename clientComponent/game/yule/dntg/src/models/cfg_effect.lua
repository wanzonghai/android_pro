local par = function(key, file)
	return {key=key, type="par", file=file}
end
local csb = function(key, file, name)
	return {key=key, type='csb', file=file, name=name}
end
local frm = function(key, fmt, min, max, inteval)
	return {key=key, type='frm', fmt=fmt, min=min, max=max, inteval=inteval}
end
local spi = function(key, file, name, skin)
	return {key = key, type='spi', json=file..'.json', atlas=file..'.atlas', name=name, image=file..'.png', skin=skin}
end

local plist = function(file)
	return {type='plist', plist=file..'.plist', image=file..'.png'}
end

local anima = function(file,key,num,time,formatBit)
     return {type='anima',file=file,key=key,num=num,time=time,formatBit=formatBit}
end

return {
	plist("xyaoqianshu/Plist"),
	plist("cannon/dntg_cannon"),
	plist("effect_bg_water/effect_bg_water_01"),
	plist("effect_bg_water/effect_bg_water_02"),
	plist("effect_bg_water/effect_bg_water_03"),
    plist("effect_bg_water/wave"),

	plist("FishEffect/fish_jinbi"),
	plist("FishEffect/fish_yinbi"),

	par('hitfish',      'xyaoqianshu/eff/hitput.plist'),

	csb('frozen',       'effect_ding/effect_ding.csb', 'animation0'),
	csb('getBigGold',   'xyaoqianshu/goldCircle.csb', 'animation0'),

	csb('WaterAnim',    'effect_bg_water/effect_bg_water.csb', 'effect_bg_water_animation'),

    spi('GoldBoom',  'FishEffect/yuboomeffect', 'animation'),
    spi('getgold',  'FishEffect/jinbishounaeffect', 'animation'),
    --spi('tips_wukong', 'FishEffect/2dboostips', 'animation', '1'),
    --spi('tips_yudi', 'FishEffect/2dboostips', 'animation', '2'),
    spi('tips_wukong', 'FishEffect/qitiandahseng', 'animation'),
    spi('tips_yudi', 'FishEffect/yuhuangdadi', 'animation'),
	spi('tips_yuchao',  'FishEffect/flshboomtips', 'animation'),

    spi('buff_fangsheyu', 'FishEffect/danaotiangong', 'idle', '1'),

    spi('buff_combine5_idle', 'FishEffect/jinyumantang', 'idle'),
    spi('buff_combine3_idle', 'FishEffect/yishisanyu', 'idle'),
    spi('buff_combine2_idle', 'FishEffect/yijianshuangdiao', 'idle'),
    spi('buff_combine5_dead', 'FishEffect/jinyumantang', 'end'),
    spi('buff_combine3_dead', 'FishEffect/yishisanyu', 'end'),
    spi('buff_combine2_dead', 'FishEffect/yijianshuangdiao', 'end'),


    csb('buff_shandian', 'FishEffect/shandianmenu.csb', 'idle'),
    csb('eff_foshou', 'FishEffect/foshouzidan.csb', 'animation0'),

    spi('eff_flash_node', 'FishEffect/shandianxianjie', 'animation'),
    spi('eff_flash_line', 'FishEffect/shandianliansuo', 'idle'),

    csb('eff_jinbi', 'FishEffect/fish_jinbi.csb', 'start'),
    csb('eff_yinbi', 'FishEffect/fish_yinbi.csb', 'start'),

    --’Î∂‘÷°∂Øª≠
    anima("wave_","waveAnim",2,0.4,1),

    -- frm('eff_jinbi', 'FishEffect/fish_jinbi4_%d.png', 1, 6, 0.03),
    -- frm('eff_yinbi', 'FishEffect/fish_yinse_jinbi4_%d.png', 1, 6, 0.03),
    -- csb('eff_yinbi', 'FishEffect/fish_yinbi.csb', 'start'),
}