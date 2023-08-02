ZORDER = g_ExternalFun.enum{
    "DEFAULT = 10",   --通用
    "MARQUEE = 50",   --跑马灯
    "POPUP = 100",    --2级弹框
    "REWARD = 101",    --领取奖励界面
}

local UIMgr = class('UIMgr', function()
    return ccui.Layout:create():setContentSize(display.width, display.height)
end)

function UIMgr:ctor(args)
    self.rootLayer = ccui.Layout:create()
    self.rootLayer:setContentSize(display.width, display.height)
    self.rootLayer:setTouchEnabled(false)
    self.rootLayer:addTo(self, 1)

    self.msgNode = display.newNode():addTo(self, 100000)

    if type(args) == "string" then
        self.args = {prefix=args} 
    else
        self.args = args
    end
    self.layers = {}
end

function UIMgr:showPopWaitWithTime(time, ...)
    if self.popWait then
        return
    end

    local popwait = self.args.popwait or appdf.CLIENT_SRC .. 'ui.PopWait'

    self.popWait = require(popwait).new(...)
    self.popWait:addTo(self, 2)
    if time then
        self.popWait:runAction(cc.Sequence:create(cc.DelayTime:create(time), 
                                                    cc.CallFunc:create(function()
                                                        self:closePopWait()
                                                    end)))
    end
end

function UIMgr:showPopWait(...)
    print("UIMgr:showPopWait")
    return self:showPopWaitWithTime(nil, ...)
end

function UIMgr:dismissPopWait()
    self:closePopWait()
end

function UIMgr:closePopWait()
    print("UIMgr:closePopWait")
    if not self.popWait then
        return
    end
    self.popWait:removeSelf()
    self.popWait = nil
end

function UIMgr:showToast(msg, time)
    -- showToast(self.msgNode, msg, time or 1)
end

function UIMgr:_setupBlackLayer() 
    self.blackLayer = ccui.Layout:create()
    self.blackLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self.blackLayer:setBackGroundColor(ccc3(0,0,0))
    self.blackLayer:setBackGroundColorOpacity(180)
    self.blackLayer:setContentSize(cc.size(display.width, display.height))
    self.blackLayer:setTouchEnabled(true)
    self.blackLayer:setVisible(false)
    self.rootLayer:addChild(self.blackLayer)
end

function UIMgr:_reorderBlackLayer(z)
    local count = #self.layers
    local bgVisible = (count ~= 0)
    local newz = z and z or count*2+1

    if not self.blackLayer then
        self:_setupBlackLayer() 
    end
    self.blackLayer:setVisible(bgVisible)
    self.blackLayer:setTouchEnabled(bgVisible)
    self.blackLayer:setLocalZOrder(newz)
end

function UIMgr:close_(inst_or_name, effect, event)
    local closed, index = self:find(inst_or_name) 

    if not closed then
        return
    end

    table.remove(self.layers, index)

    if event and closed.onClose then
        for i, v in ipairs(closed.onClose) do
            v(closed.inst)
        end
    end

    self:resetAllLayer()


    if effect then
        closed.inst:runAction(transition.sequence{
            transition.newEasing(cc.ScaleTo:create(0.2, 0.2), "BACKIN"),
            cc.RemoveSelf:create(),
        })
    else
        closed.inst:removeSelf()
    end
end

function UIMgr:quietClose(inst_or_name) 
    self:close_(inst_or_name, false, false)
end

function UIMgr:close(inst_or_name, effect, event) 
    if effect == nil then effect = true end
    if event == nil then event = true end

    self:close_(inst_or_name, effect, event)
end

function UIMgr:resetAllLayer()
    for i, v in ipairs(self.layers) do
        v.inst:setLocalZOrder(i*2 + 2)
    end

    self:_reorderBlackLayer()
end


function UIMgr:pop()
    local info = self.layers[#self.layers]
    if info then
        self:close(info.inst)
    end
end

function UIMgr:push(instance, name)
    local last = self.layers[#self.layers]

    local info = {inst = instance, name = name}
    table.insert(self.layers, info)

    instance.mgr = self
    instance:addTo(self.rootLayer)

    instance:setLocalZOrder(#self.layers * 2 + 2)
    self:_reorderBlackLayer()
end

function UIMgr:clear()
    for i, v in ipairs(self.layers) do
        v.inst:removeSelf()
    end

    self.layers = {}
    self:_reorderBlackLayer()
end

function UIMgr:isEmpty()
    return (#self.layers == 0)
end

function UIMgr:find(inst_or_name)
    for i, v in ipairs(self.layers) do
        if v.name == inst_or_name or v.inst == inst_or_name then
            return v, i
        end
    end
end

function UIMgr:onClose(inst_or_name, func)
    local info = self:find(inst_or_name)
    if not info then return end

    if not info.onClose then
        info.onClose = {}
    end

    table.insert(info.onClose, func)
end

function UIMgr:open(name, ...)
    local fullname = self.args.prefix .. "."..name
    print("open", fullname)
    local inst = require(fullname).new(...)
    self:push(inst, name)
    return inst
end

function UIMgr:blink(name, ...)
    local fullname = self.args.prefix .. "."..name
    print("open", fullname)
    local inst = require(fullname).new(...)
    self:push(inst, name)

    inst:setScale(0.2)
    inst:runAction(transition.sequence{
        transition.newEasing(cc.ScaleTo:create(0.2, 1), "BACKOUT")
    })

    return inst
end

return UIMgr
