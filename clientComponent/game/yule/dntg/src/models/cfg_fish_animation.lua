local function spine(id)
	return {
		kind=id,
		type="s",
		image=string.format("fish/%03d.png", id),
		json=string.format("fish/%03d.json", id),
		atlas=string.format("fish/%03d.atlas", id),
	}
end

local function frame(id, idle, dead, pfx)
	return {
		kind=id,
		type="f",
		image=string.format("fish/%03d.png", id),
		plist=string.format("fish/%03d.plist", id),
		idle = {
			fmt=pfx .. "-idle_%d.png",
			min=0, max=idle,
		},

		dead= {
			fmt=pfx .. "-end_%d.png",
			min=0, max=dead,
		},
	}
end

local function csb(id)
	return {
		kind=id,	
		type='c',
		image=string.format('fish/%03d.png', id),
		plist=string.format('fish/%03d.plist', id),
		csb=string.format('fish/%03d.csb', id),
	}
end

return {
	frame(1, 40, 6, "xiaolvyu"),
	frame(2, 40, 6, "xiaolvyu2"),
	frame(3, 30, 6, "xiaolanyu"),
	frame(4, 35, 6, "buyu8"),
	frame(5, 40, 6, "buyu10"),
	frame(6, 25, 8, "xiaochouyu"),
	frame(7, 20, 8, "hetun"),
	frame(8, 25, 8, "buyu13"),
	frame(9, 30, 8, "denglongyu"),
	frame(10, 35, 12, "xiaohaigui"),
	frame(11, 12, 1, "houtouyu"),
	csb(12),
	spine(13),
	spine(14),
	spine(15),
	spine(16),
	spine(17),
	spine(18),
	spine(19),
	spine(20),
	spine(21),
	spine(22),
	spine(23),
	spine(24),
	spine(25),
	spine(26),
	spine(27),
	spine(28),
	spine(29),
	spine(30),
	spine(31),
}