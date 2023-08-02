
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene,transition, time, more)
    return self
end

function ViewBase:onEnter()
    self:addKeyBoard()
end

function ViewBase:addKeyBoard( ... )
    
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
            self:onExitApp()
        elseif code == cc.KeyCode.KEY_HOME then
            cc.Director:getInstance():endToLua()
        end
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    
    local eventDispatcher =self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    return self
end

function ViewBase:onExitApp( ... )    
    if ylAll.QuitLayer and not tolua.isnull(ylAll.QuitLayer) then
        return
    else
    end
    local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
    local msg = "Tem certeza de que deseja sair do jogo?"
    local dialog = QueryDialog:create(msg,function(bConfirm)
        ylAll.QuitLayer = nil    
        if bConfirm == true then                    	
            os.exit(0)            
        end					
    end)
    ylAll.QuitLayer = dialog
    self:getParent():addChild(dialog,100000)
end

return ViewBase
