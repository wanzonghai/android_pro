--
-- Author: senji
-- Date: 2014-02-13 18:21:09
--

local UIManager = class_quick("UIManager");

SceneType = {};
SceneType.scene_login = "LoginScene"
SceneType.scene_fullui = "FullUIScene" --全屏ui的scene
SceneType.scene_plaza = "PlazaScene" --主界面scene

local function initSomeConsts()
    display.gameLeft = (display.width - CUR_SELECTED_WIDTH) * .5;
    display.gameRight = display.width - display.gameLeft
    display.gameBottom = (display.height - CUR_SELECTED_HEIGHT) * .5;
    display.gameTop = display.height - display.gameBottom;

    printInfo(string.format("# display.gameLeft                 = %0.2f", display.gameLeft))
    printInfo(string.format("# display.gameRight                 = %0.2f", display.gameRight))
    printInfo(string.format("# display.gameBottom                 = %0.2f", display.gameBottom))
    printInfo(string.format("# display.gameTop                 = %0.2f", display.gameTop))
end

initSomeConsts()


local function createLayer()
    local result = display.newLayer();
    result:setAnchorPoint(cc.p(0, 0));
    -- result:setContentSize(cc.size(CONFIG_CUR_HEIGHT, CONFIG_CUR_WIDTH))--shengsmark 这里是不是长宽调转了？
    result:setContentSize(cc.size(CUR_SELECTED_WIDTH, CUR_SELECTED_HEIGHT))
    result:retain();
    return result;
end

-- print("设置contentscalefactor:", display.contentScaleFactor)
-- cc.Director:getInstance():setContentScaleFactor(display.contentScaleFactor)

function UIManager:ctor()
    self._mainSceneTypes = {}
    self._curShowingModuleDic = {} --hash, key Module的proxy， value:true
    createSetterGetter(self, "isHidingAllModules", false);
    createSetterGetter(self, "hideAllModulesToSceneType", nil, false, true);
    createSetterGetter(self, "meshLayer", nil);
    createSetterGetter(self, "mapLineLayer", nil);
    createSetterGetter(self, "curScene", nil, false, true);
    createSetterGetter(self, "curMainSceneType", nil, false, true);
    createSetterGetter(self, "topLayerInAllScene", nil);
    createSetterGetter(self, "curSceneType", nil, false, true);
    createSetterGetter(self, "isWorldTouchable", true, false, true);
    createSetterGetter(self, "canSetWorldTouchable", true); --是否能设置isWorldTouchable这个属性
    createSetterGetter(self, "isScreenOrientationRotated", false, true, nil, nil, nil, handler(self, self.onIsScreenOrientationRotatedChanged));
    createSetterGetter(self, "isHMaskVisible", true, false, nil, nil, nil, handler(self, self.onHMaskVisibleChanged));
    self._worldMaskLayout = nil;
    self._curUiLayer = nil;
    self._curSceneType = nil;
    self._scenes = {};
    self._uiLayerDic = {};
    self._outSideMaskersDic = {}
    self._mapConverCacheDic = {}


    self._sceneSwitcherFade = nil;
    self._sceneSwitcherLoading = nil;
    self:initLayers();
end


function UIManager:onIsScreenOrientationRotatedChanged()
    bridgeMgr:setStatusBarOrientation(not self._isScreenOrientationRotated)
    bridgeMgr:setAutorotate(not self._isScreenOrientationRotated)
    local function swap(a, b)
        return b, a
    end

    CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT = swap(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT)
    CONFIG_WIDTH_SHORT, CONFIG_HEIGHT_SHORT = swap(CONFIG_WIDTH_SHORT, CONFIG_HEIGHT_SHORT)
    CONFIG_WIDTH_LONG, CONFIG_HEIGHT_LONG = swap(CONFIG_WIDTH_LONG, CONFIG_HEIGHT_LONG)
    CONFIG_CUR_WIDTH, CONFIG_CUR_HEIGHT = swap(CONFIG_CUR_WIDTH, CONFIG_CUR_HEIGHT)
    CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT = swap(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
    CUR_SELECTED_WIDTH, CUR_SELECTED_HEIGHT = swap(CUR_SELECTED_WIDTH, CUR_SELECTED_HEIGHT)

    display.sizeInPixels.width, display.sizeInPixels.height = swap(display.sizeInPixels.width, display.sizeInPixels.height)
    display.size.width, display.size.height = swap(display.size.width, display.size.height)
    display.setConstants(display.sizeInPixels, display.size)
    initSomeConsts()


    -- ios和android的处理方式是不一样的，ios上面是不会旋转glview的，但是android上面则会
    -- 所以处理方式上面ios需要特别兼容一下某些界面
    if isAndroid then
        local view = cc.Director:getInstance():getOpenGLView()
        local frameSize = view:getFrameSize()
        view:setFrameSize(frameSize.height, frameSize.width)
        view:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)

        self:maskGameOutSideArea(nil, true)
    else
        --下面这个旋转只有ios上面是要这样操作
        CcsScrollView.isScreenOrientationRotated = self._isScreenOrientationRotated
        if self._isScreenOrientationRotated then
            local offset = display.height
            self._curUiLayer:setRotation(-90)
            self._curUiLayer:setPositionX(offset)
            self._topLayerInAllScene:setRotation(-90)
            self._topLayerInAllScene:setPositionX(offset)
        else
            self._curUiLayer:setRotation(0)
            self._topLayerInAllScene:setRotation(0)
            self._curUiLayer:setPositionX(0)
            self._topLayerInAllScene:setPositionX(0)
        end
    end
end

function UIManager:setIsWorldTouchable(b)
    if self._isWorldTouchable ~= b and self._canSetWorldTouchable then
        self._isWorldTouchable = b;
        self:onWorldTouchableChanged();
    end
end

function UIManager:setCurScene(scene,sceneType)
    self._scenes[sceneType] = scene
    self._curScene = scene
    local uiLayer = self:getUILayerByScene(sceneType)
    self:setCurUiLayer(uiLayer)
end

function UIManager:getSceneByType(sceneType)
    return cc.Director:getInstance():getRunningScene()
    --[[local result = self._scenes[sceneType]
    if not result then
        result = display.newScene(sceneType);
        result:retain();
        self._scenes[sceneType] = result;
    end

    return result;]]
end


function UIManager:destroyScene(sceneType)
    local scene = self._scenes[sceneType];
    if scene then
        scene:release();
        self._scenes[sceneType] = nil;
    end

    local uilayer = self._uiLayerDic[sceneType]
    if uilayer then
        uilayer:removeFromParent();
        uilayer:release();
        self._uiLayerDic[sceneType] = nil;
    end
end

function UIManager:showScene(sceneType, onFinishCallback, onMiddleCallback, noAnimation, forceSwitch, switchDelay, middleDelay, isSwitchLoadingOrFade)
    if not IS_SCENE_VIEW_SWITCH_ANIMATION then
        noAnimation = true;--官包没有切换效果，现在全部不要黑色切换
    end
    local newScene = self:getSceneByType(sceneType);
    if newScene and (self._curScene ~= newScene or true) then
        -- self:setIsCocosBgTransparent(sceneType == SceneType.scene_plaza);
        local uiLayer = self:getUILayerByScene(sceneType)
        local oldScene = self._curScene;
        local oldSceneType = self._curSceneType
        self._curScene = newScene;
        self._curSceneType = sceneType;
        if not self:getIsHidingAllModules() and self:isMainScene(sceneType) then
            self._curMainSceneType = sceneType;
        end
        print("更新scene类型", sceneType)


        local function onSceneReplaceMiddle()
            self:maskGameOutSideArea(newScene)
            if ProxyDebugLog then
                ProxyDebugLog:deployAtScene(newScene);
            end
            applyFunction(onMiddleCallback, { oldSceneType });
        end

        local function onSceneReplaceComplete()
            applyFunction(onFinishCallback);
        end

        if not noAnimation then
            local switcher = nil
            if isSwitchLoadingOrFade then
                if not self._sceneSwitcherLoading then
                    self._sceneSwitcherLoading = SceneSwitcherLoading.new();
                end
                switcher = self._sceneSwitcherLoading;
            else
                if not self._sceneSwitcherFade then
                    self._sceneSwitcherFade = SceneSwitcherFade.new();
                end
                switcher = self._sceneSwitcherFade;
            end
            switcher:switchTo(oldScene, newScene, self._curUiLayer, uiLayer, onSceneReplaceComplete, onSceneReplaceMiddle, switchDelay, middleDelay)
        else
            --display.runScene(self._curScene);
            self:setCurUiLayer(uiLayer);
            eventMgr:dispatch(GameEvent.OnSceneChanged);
            onSceneReplaceMiddle();
            onSceneReplaceComplete();
        end
    end
end

function UIManager:onHMaskVisibleChanged()
    if not IS_ADJUST_SLIM_WIDTH then
        self._isHMaskVisible = true
    end
    local leftMask = self._outSideMaskersDic[3]
    local rightMask = self._outSideMaskersDic[4]
    if leftMask then
        leftMask:setVisible(self._isHMaskVisible)
    end
    if rightMask then
        rightMask:setVisible(self._isHMaskVisible)
    end
end


-- 把游戏区域外的都屏蔽起来
function UIManager:maskGameOutSideArea(scene, forceReset)
    if not isNoMask4Resolution then
        scene = scene or self._curScene
        if self._initMask and not forceReset then
            for k,v in pairs(self._outSideMaskersDic) do
                DisplayUtil.setAddOrRemoveChild(v, scene, true);
            end
        else
            self._initMask = true;
            local maskers = {};

            -- pos：1，2，3，4 分辨是上，下，左，右
            local function getMask(pos)
                local mask = self._outSideMaskersDic[pos];
                self._outSideMaskersDic[pos] = nil;
                if not mask then
                    mask = ccui.Layout:create();
                    mask:setAnchorPoint(ccp(0, 0))
                    mask:setBackGroundColorType(1)
                    mask:setBackGroundColor(cc.c4b(0, 0, 0, 255));
                    mask:setLocalZOrder(ZORDER_GAME_OUTSIDE_MASK);

                    -- if pos == 1 then
                    --     resMgr:loadTextureAtlas(ResConfig.getSpriteSheetPath("main_mask.plist"));
                    --     local bgUp = display.newSprite("#main_mask_down.png");
                    --     bgUp:setAnchorPoint(ccp(0, 0));
                    --     bgUp:setPosition(0, 0);
                    --     mask:addChild(bgUp);
                    -- elseif pos == 2 then
                    --     resMgr:loadTextureAtlas(ResConfig.getSpriteSheetPath("main_mask.plist"));
                    --     local bgDown = display.newSprite("#main_mask_up.png");
                    --     bgDown:setAnchorPoint(ccp(0, 0));
                    --     bgDown:setPosition(0, display.height - bgDown:getContentSize().height);
                    --     mask:addChild(bgDown);
                    -- end

                    mask:retain();
                end
                mask:setContentSize(cc.size(display.width, display.height));
                maskers[pos] = mask;
                DisplayUtil.setAddOrRemoveChild(mask, scene, true);
                mask:setTouchEnabled(true); --注意这里要再设置一次，因为removeChild之后会立刻设置为false

                --mask:setVisible(false);--shengsmark，测试时先隐藏

                return mask;
            end

            if display.height > CUR_SELECTED_HEIGHT then
                local offset = display.gameBottom;
                local maskUp = getMask(1);
                maskUp:setPosition(0, offset + CUR_SELECTED_HEIGHT);

                local maskBottom = getMask(2);
                maskBottom:setPosition(0, offset - maskBottom:getContentSize().height);
                if isAndroid then
                    if self._isScreenOrientationRotated then
                        --旋屏时，上下遮照要判断是否要显示
                        maskUp:setVisible(self._isHMaskVisible)
                        maskBottom:setVisible(self._isHMaskVisible)
                    else
                        maskUp:setVisible(true);
                        maskBottom:setVisible(true);
                    end
                end
            end
            if display.width > CUR_SELECTED_WIDTH then
                local offset = display.gameLeft;

                local maskLeft = getMask(3);
                maskLeft:setPosition(offset - maskLeft:getContentSize().width, 0);


                local maskRight = getMask(4);
                maskRight:setPosition(offset + CUR_SELECTED_WIDTH, 0);
                
                maskLeft:setVisible(self._isHMaskVisible)
                maskRight:setVisible(self._isHMaskVisible)
            end

            for pos, mask in pairs(self._outSideMaskersDic) do
                mask:removeFromParent();
                mask:release();
            end

            self._outSideMaskersDic = maskers;
        end
        -- print("mask数量", #maskers)
    end
end

function UIManager:getCurUiLayer()
    return self._curUiLayer
end

function UIManager:setCurUiLayer(layer)
    if self._curUiLayer ~= layer then
        self._curUiLayer = layer;
    end
    DisplayUtil.addChild2(layer, self._curScene);
    DisplayUtil.addChild2(self._topLayerInAllScene, self._curScene);
    self:onWorldTouchableChanged();
end

function UIManager:getUILayerByScene(sceneType)
    local uiLayer = self._uiLayerDic[sceneType]
    if not uiLayer then
        uiLayer = createLayer();
        uiLayer._sceneType = sceneType
        self._uiLayerDic[sceneType] = uiLayer;
    end
    return uiLayer;
end

function UIManager:onRemoveCurLayerChild()
    if self._curUiLayer then
        self._curUiLayer:removeAllChildren()
    end
end

-- 居中显示
function UIManager:centerLocate(node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    self:locate(UIConfig.ALIGN_CENTER, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY);
end

-- 左上角
function UIManager:leftUpLocate(node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    self:locate(UIConfig.ALIGN_LEFT_UP, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY);
end

-- 左下角
function UIManager:leftDownLocate(node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    self:locate(UIConfig.ALIGN_LEFT_DOWN, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY);
end

-- 右下角
function UIManager:rightDownLocate(node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    self:locate(UIConfig.ALIGN_RIGHT_DOWN, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY);
end

--  右上角
function UIManager:rightUpLocate(node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    self:locate(UIConfig.ALIGN_RIGHT_UP, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY);
end



function UIManager:adjustSlimWidth(node, mode, offsetXInSlimWidth, offsetYInSlimWidth)
    if not IS_ADJUST_SLIM_WIDTH then
        return;
    end
    if not node or node.__hasAdjustIphonex then
        return;
    end
    offsetXInSlimWidth = offsetXInSlimWidth or 0;
    offsetYInSlimWidth = offsetYInSlimWidth or 0;
    local deltaWidth = display.width - CUR_SELECTED_WIDTH
    local deltaHeight = display.height - CUR_SELECTED_HEIGHT
    local pos = nil;
    if mode == 1 then --左上
        pos = cc.p(-deltaWidth * .5, 0)
    elseif mode == 2 then --左中
        pos = cc.p(-deltaWidth * .5, 0)
    elseif mode == 3 then --左下
        pos = cc.p(-deltaWidth * .5, 0)
    elseif mode == 4 then --下中
        pos = cc.p(0, -deltaHeight * .5)
    elseif mode == 5 then --右下
        pos = cc.p(deltaWidth * .5, 0)
    elseif mode == 6 then --右中
        pos = cc.p(deltaWidth * .5, 0)
    elseif mode == 7 then --右上
        pos = cc.p(deltaWidth * .5, 0)
    elseif mode == 8 then --上中
        pos = cc.p(0, deltaHeight * .5)
    end
    if math.abs(deltaWidth * .5) < 10 then
        offsetXInSlimWidth = 0;
    end
    if math.abs(deltaHeight * .5) < 10 then
        offsetYInSlimWidth = 0;
    end

    local x, y = node:getPosition();
    node.__hasAdjustIphonex = true
    node:setPosition(x + pos.x + offsetXInSlimWidth, y + pos.y + offsetYInSlimWidth)
end

-- mode的参数如下
-- 0 居中
-- 1 左上
-- 2 左中
-- 3 左下
-- 4 下中
-- 5 右下
-- 6 右中
-- 7 右上
-- 8 上中
-- isAlign2GameAreaOrScreen ：
-- true：以CUR_SELECTED_WIDTH和CUR_SELECTED_HEIGHT的游戏区域为准
-- false ：对齐的方式是以屏幕尺寸为准
function UIManager:locate(mode, node, nodeWidth, nodeHeight, isAlign2GameAreaOrScreen, offsetX, offsetY)
    if mode == UIConfig.ALIGN_NO then
        return;
    end
    nodeWidth = nodeWidth or CONFIG_DESIGN_WIDTH;
    nodeHeight = nodeHeight or CONFIG_DESIGN_HEIGHT;
    local winWidth = display.width;
    local winHeight = display.height;


    offsetX = offsetX or 0
    offsetY = offsetY or 0;
    if isAlign2GameAreaOrScreen == nil then
        isAlign2GameAreaOrScreen = UIConfig.uiAlign2GameAreaOrScreen
    end

    if isAlign2GameAreaOrScreen then -- 对非黑边区域
        winWidth = CUR_SELECTED_WIDTH;
        winHeight = CUR_SELECTED_HEIGHT;

        offsetX = (display.width - winWidth) * .5;
        offsetY = (display.height - winHeight) * .5;
    end
    DisplayUtil.locateReal(mode,
        node,
        winWidth,
        winHeight,
        nodeWidth,
        nodeHeight,
        offsetX,
        offsetY);
end

-- 显示界面
function UIManager:showView(view, zOrder, toParent)
    toParent = toParent or self._curUiLayer
    zOrder = zOrder or ZORDER_UI_DEFAULT;
    view:setLocalZOrder(zOrder);
    DisplayUtil.setAddOrRemoveChild(view, toParent, true)
end

function UIManager:initLayers()
    self._topLayerInAllScene = createLayer();
    self._topLayerInAllScene:setGlobalZOrder(ZORDER_TOP_LAYER_IN_ALL_SCENE);
    --dndMgr:deploy(self._topLayerInAllScene);
end

function UIManager:onWorldTouchableChanged()
    -- print("世界能否点击：", self._isWorldTouchable)
    if self._isWorldTouchable then
        if self._worldMaskLayout then
            self._worldMaskLayout:removeFromParent();
            self._worldMaskLayout:release();
            self._worldMaskLayout = nil;
        end
    else
        if not self._worldMaskLayout then
            self._worldMaskLayout = ccui.Layout:create();
            self._worldMaskLayout:setContentSize(cc.size(CUR_SELECTED_WIDTH, CUR_SELECTED_HEIGHT));
            self._worldMaskLayout:setAnchorPoint(cc.p(0.5, 0.5))
            self._worldMaskLayout:setPosition(display.cx, display.cy);
            self._worldMaskLayout:setBackGroundColorType(0);
            self._worldMaskLayout:setBackGroundColor(cc.c4b(255, 0, 0, 255))
            self._worldMaskLayout:setBackGroundColorOpacity(100)
            self._worldMaskLayout:retain()
        end
        self._worldMaskLayout:setTouchEnabled(true);
        self._worldMaskLayout:setLocalZOrder(ZORDER_WORLD_TOUCH_BLOCK_LAYOUT);
        self:showView(self._worldMaskLayout)
    end
end

function UIManager:addOrRemoveShowingModule(moduleProxy, isShowing)
    if not moduleProxy then
        return;
    end
    if isShowing then
        self._curShowingModuleDic[moduleProxy] = true
    else
        self._curShowingModuleDic[moduleProxy] = nil
    end
end

-- 是否主要的场景类型
function UIManager:isMainScene(sceneType)
    return sceneType ~= nil and self._mainSceneTypes[sceneType] ~= nil;
end

uiMgr = UIManager.new();

--单件