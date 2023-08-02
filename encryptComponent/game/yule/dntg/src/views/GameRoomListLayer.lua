local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."gamemodel.NewRoomList")
local GameRoomListLayer = class("GameRoomListLayer", RoomListLayer)

function GameRoomListLayer:ctor(scene, frameEngine, isQuickStart)
	RoomListLayer.ctor(self, scene, frameEngine, isQuickStart)

	local csbNode = self:setup("xyaoqianshu/RoomList.csb")

	for i = 1, 5 do
		local btn = csbNode:getChildByName("b" .. i)
		local node = btn:getChildByName("p")

		local spineBg = sp.SkeletonAnimation:create("xyaoqianshu/roomlist/skeleton/btn" .. i .. "_bg.json", "xyaoqianshu/roomlist/skeleton/btn" .. i .. "_bg.atlas", 1)
		spineBg:setAnimation(0, "animation", true)
		spineBg:addTo(node)

		local spineRole = sp.SkeletonAnimation:create("xyaoqianshu/roomlist/skeleton/btn" .. i .. "_role.json", "xyaoqianshu/roomlist/skeleton/btn" .. i .. "_role.atlas", 1)
		spineRole:setAnimation(0, "animation", true)
		spineRole:setPosition(0, 128)
		spineRole:addTo(node)

		local spinePanel = sp.SkeletonAnimation:create("xyaoqianshu/roomlist/skeleton/btn" .. i .. "_panel.json", "xyaoqianshu/roomlist/skeleton/btn" .. i .. "_panel.atlas", 1)
		spinePanel:setAnimation(0, "animation", true)
		spinePanel:addTo(node)

		if not btn.roomInfo then
			spineBg:setColor(cc.c3b(125,125,125))
			spineRole:setColor(cc.c3b(125,125,125))
			spinePanel:setColor(cc.c3b(125,125,125))
		end
	end
end

return GameRoomListLayer