local BaseNode = class("BaseNode",function() 
    return ccui.Layout:create()
end)

function BaseNode:ctor()
    self.mainNode = nil
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end
    self:setTouchEnabled(false)
    self:registerScriptHandler(onNodeEvent)
end

function BaseNode:addLayer(pathName)
    self.mainNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(pathName)
    self.mainNode:removeSelf()
    self:addChild(self.mainNode,-10)
    self.mainNode:setPosition(cc.p(0,0))
    self:setTouchEnabled(false)
end

function BaseNode:getChildByName(name,node)
    node = node or self.mainNode
	local curNode = node:getChildByName(name)
	if curNode then
		return curNode
	else
		local nodeTab = node:getChildren()
		if #nodeTab>0 then		
			for i=1,#nodeTab do
				local  result = self:getChildByName(name,nodeTab[i])
				if result then					
					return result
				end 
			end
		end

	end
    return nil
end

function BaseNode:onEnter()

end

function BaseNode:onExit()
    self:unregisterScriptHandler()
end

return BaseNode