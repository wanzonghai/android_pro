
local HelpLayer = class("Quit", cc.Layer)

function HelpLayer:ctor(func)
	local csb = ef.loadCSB("xyaoqianshu/Quit.csb", self)

	local function close(ok)
		func(ok)
		self.mgr:close(self)
	end
    csb:getChildByName("close"):setPressButtonMusicPath("sound/btn_close.mp3")
	csb:getChildByName("close"):addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.ended then
           close(ok)
        end
    end)
    local btnCancel = csb:getChildByName("cancel")
    local btnOk = csb:getChildByName("ok")
    btnCancel:onClickEnd(bind(close, false))
    btnOk:onClickEnd(bind(close, true))
	local posx1,posy1 = btnCancel:getPosition()
	local posx2,posy2 = btnOk:getPosition()
    btnCancel:setPosition(posx2,posy2)
    btnOk:setPosition(posx1,posy1)
	local label = csb:getChildByName('time')
	local time = 9
	label:setString(9)
    label:setPositionX(label:getPositionX()-50)
    label:setPositionY(label:getPositionY() -7)
	self:runAction(
		cc.Repeat:create(
			cc.Sequence:create({
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					time = time - 1
					label:setString(time)
					if time == 0 then
						close(false)
					end
				end)
			}), 
			9)
		)	
end

return HelpLayer