
local moveVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec3 a_texCoord;\n"..
"uniform float ratio; \n"..
"uniform float radius; \n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec4 v_fragmentColor;\n"..
"varying vec2 v_texCoord;\n"..
"uniform float isRatote;\n"..
"uniform mat4 matRotate;\n"..
"uniform mat4 translate1;\n"..
"uniform mat4 translate2;\n"..
"uniform mat4 scaleMat;\n"..

"void main()\n"..
"{\n"..
"   vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);\n"..
"   tmp_pos = vec4(a_position.x, a_position.y, 1.0, 1.0);\n"..
"   float start_posx = tmp_pos.x;\n"..
"   float start_posy = tmp_pos.y;\n"..
"   float halfPeri = radius * 3.14159; \n"..
"   float hw = width * ratio;\n"..
"   if(isRatote >0.5){\n"..
"      if(hw > 0.0 && hw <= halfPeri){\n"..
"            if(tmp_pos.x < hw){\n"..
"                  float rad = hw/ 3.14159;\n"..
"                  float arc = (hw-tmp_pos.x)/rad;\n"..
"                  tmp_pos.x = hw - sin(arc)*rad;\n"..
"                  tmp_pos.z = 0.0;//rad * (1.0-cos(arc)); \n"..
"             }\n"..
"      }\n"..
"      if(hw > halfPeri){\n"..
"           float straight = (hw - halfPeri)/2.0;\n"..
"           if(tmp_pos.x < straight){\n"..
"               tmp_pos.x = hw  - tmp_pos.x;\n"..
"               tmp_pos.z = 0.0;//radius * 2.0; \n"..
"           }\n"..
"           else if(tmp_pos.x < (straight + halfPeri)) {\n"..
"               float dx = halfPeri - (tmp_pos.x - straight);\n"..
"               float arc = dx/radius;\n"..
"               tmp_pos.x = hw - straight - sin(arc)*radius;\n"..
"               tmp_pos.z = 0.0;//radius * (1.0-cos(arc)); \n"..
"           }\n"..
"       }\n"..
"   }\n"..
"   else{\n"..
"      float hr = height * ratio;\n"..
"      if(hr > 0.0 && hr <= halfPeri){\n"..
"            if(tmp_pos.y < hr){\n"..
"                  float rad = hr/ 3.14159;\n"..
"                  float arc = (hr-tmp_pos.y)/rad;\n"..
"                  tmp_pos.y = hr - sin(arc)*rad;\n"..
"                  tmp_pos.z = 0.0;//rad * (1.0-cos(arc)); \n"..
"             }\n"..
"      }\n"..
"      if(hr > halfPeri){\n"..
"           float straight = (hr - halfPeri)/2.0;\n"..
"           if(tmp_pos.y < straight){\n"..
"               tmp_pos.y = hr  - tmp_pos.y;\n"..
"               tmp_pos.z = 0.0;//radius * 2.0; \n"..
"           }\n"..
"           else if(tmp_pos.y < (straight + halfPeri)) {\n"..
"               float dy = halfPeri - (tmp_pos.y - straight);\n"..
"               float arc = dy/radius;\n"..
"               tmp_pos.y = hr - straight - sin(arc)*radius;\n"..
"               tmp_pos.z = 0.0;//radius * (1.0-cos(arc)); \n"..
"           }\n"..
"       }\n"..
"    }\n"..
"    if(isRatote >0.5){\n"..
"        tmp_pos.y = start_posy;\n"..
"    }\n"..
"    else{\n"..
"       tmp_pos.x = start_posx;\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix*translate1*scaleMat*matRotate*translate2*tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, a_texCoord.y);\n"..
"}\n";

local smoothVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec3 a_texCoord;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..
"uniform mat4 matRotate;\n"..
"uniform mat4 translate1;\n"..
"uniform mat4 translate2;\n"..
"uniform mat4 scaleMat;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float start_posx = tmp_pos.x;\n"..
"    float start_posy = tmp_pos.y;\n"..
"    float cl = height/5.0;\n"..
"    float sl = (height - cl)/2.0;\n"..
"    float radii = (cl/rotation)/2.0;\n"..
"    float sinRot = sin(rotation);\n"..
"    float cosRot = cos(rotation);\n"..
"    float distance = radii*sinRot;\n"..
"    float centerY = height/2.0;\n"..
"    float poxY1 = centerY - distance;\n"..
"    float poxY2 = centerY + distance;\n"..
"    float posZ = sl*sinRot;\n"..
"    if(tmp_pos.y <= sl){\n"..
"       float length = sl - tmp_pos.y;\n"..
"       tmp_pos.y = poxY1 - length*cosRot;\n"..
"       tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    else if(tmp_pos.y < (sl+cl)){\n"..
"       float el = tmp_pos.y - sl;\n"..
"       float rotation2 = -el/radii;\n"..
"       float x1 = poxY1;\n"..
"       float y1 = posZ;\n"..
"       float x2 = centerY;\n"..
"       float y2 = posZ - radii*cosRot;\n"..
"       float sinRot2 = sin(rotation2);\n"..
"       float cosRot2 = cos(rotation2);\n"..
"       tmp_pos.y=(x1-x2)*cosRot2-(y1-y2)*sinRot2+x2;\n"..
"       tmp_pos.z=(y1-y2)*cosRot2+(x1-x2)*sinRot2+y2;\n"..
"    }\n"..
"    else if(tmp_pos.y <= height){\n"..
"        float length = tmp_pos.y - cl - sl;\n"..
"        tmp_pos.y = poxY2 + length*cosRot;\n"..
"        tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix*translate1*scaleMat*matRotate*translate2*tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.z, a_texCoord.y);\n"..
"}\n"

local endVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec3 a_texCoord;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"varying vec2 v_texCoord;\n"..
"uniform mat4 matRotate;\n"..
"uniform mat4 translate1;\n"..
"uniform mat4 translate2;\n"..
"uniform mat4 scaleMat;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix*translate1*scaleMat*matRotate*translate2*tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.z, a_texCoord.y);\n"..
"}\n"

local strFragSource =
"varying vec2 v_texCoord;\n"..
"void main()\n"..
"{\n"..
    "//TODO, 这里可以做些片段着色特效\n"..
    "gl_FragColor = texture2D(CC_Texture0, v_texCoord);\n"..
"}\n"

local RubCardLayer_Pai = 3.141592
local RubCardLayer_State_Move = 1
local RubCardLayer_State_Smooth = 2
local RubCardLayer_RotationFrame = 6
local RubCardLayer_RotationAnger = RubCardLayer_Pai/3
local RubCardLayer_SmoothFrame = 6
local RubCardLayer_SmoothAnger = RubCardLayer_Pai/6

GlobalRubCardLayer = {}

local GlobalRubCardRes = {}

function GlobalRubCardLayer:initCardVertex(size,isBack)
    local nDivX = 30 --将宽分成30份
    local nDivY = 20 --将宽分成20份

    local verts = {} --位置坐标
    local texs = {} --纹理坐标

    local dh = size.width/nDivY
    local dw = size.height/nDivX

    local allWidth = size.width
    local allHeight = size.height

    local rect = cc.rect(0,0,size.width,size.height)

    for c = 1 ,nDivX do
        for r = 1, nDivY do 
            local x, y = (c-1)*dw, (r-1)*dh
            local quad = {}
            if isBack then
                quad = {x, y, x+dw, y, x, y+dh, x+dw, y, x+dw, y+dh, x, y+dh}
            else
                quad = {x, y, x, y+dh, x+dw, y, x+dw, y, x, y+dh, x+dw, y+dh}
            end
            for i=1,6 do
                local quadX = quad[i*2-1]
                local quadY = quad[i*2]
                local numX;
                local numY ; 
                local numX2 ;
                numX =  ((rect.x+allWidth-quadY)/allWidth)
                numY =  ((rect.y+quadX)/allHeight)
                numX2 = ((rect.x+quadY)/allWidth)

                table.insert(texs, math.max(0,numX));
                table.insert(texs, math.max(0,numY));
                table.insert(texs, math.max(0,numX2));
            end
            --[[for i=1,6 do
                local quadX = quad[i*2-1]
                local quadY = quad[i*2]
                local numX;
                local numY ; 
                local numX2 ;

                numX =  ((rect.x+allWidth-quadY)/allWidth)
                numY =  ((rect.y+quadX)/allHeight)
                numX2 = ((rect.x+quadY)/allWidth)

                table.insert(texs, math.max(0,numX));
                table.insert(texs, math.max(0,numY));
                table.insert(texs, math.max(0,numX2));
            end]]
            for _, v in ipairs(quad) do table.insert(verts, v) end
        end
    end

    local res = {}
    local tmp = {verts,texs}
    for _, v in ipairs(tmp) do 
        local buffid = gl.createBuffer()  --正面
        gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
        gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
        gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        table.insert(res, buffid)
    end
    table.insert(GlobalRubCardRes,{res,verts,texs,#verts})
end

GlobalRubCardLayer:initCardVertex(cc.size(400,580),true)
GlobalRubCardLayer:initCardVertex(cc.size(400,580),false)


local function EJExtendUserData(luaCls, cObj)
    local t = tolua.getpeer(cObj)
    if not t then
        t = {}
        tolua.setpeer(cObj, t)
    end
    setmetatable(t, luaCls)
    return cObj 
end

function GlobalRubCardLayer:create(szBack, szFont,szActFont, posX, posY,scale,isTouch,endCallBack)
    local layer = EJExtendUserData(GlobalRubCardLayer, cc.Layer:create())
    self.__index = self
    layer:__init(szBack, szFont,szActFont,posX, posY,scale,isTouch,endCallBack)
    self._moveTimeID = 0
    return layer
end

function GlobalRubCardLayer:__init(szBack, szFont, szActFont,posX, posY,scale,isTouch,endCallBack)
    self.posX = posX
    self.posY = posY
    self.newPosX = posX
    self.newPosY = posY
    self.szBack = szBack
    self.szFont = szFont
    self.szActFont = szActFont
    self.endCallBack = endCallBack
    self.scale = scale or 1

    self.isTouch = isTouch or true
    local glNode = gl.glNodeCreate()
    self.glNode = glNode
    self:addChild(glNode)
    local moveGlProgram = cc.GLProgram:createWithByteArrays(moveVertSource, strFragSource)
    self.moveGlProgram = moveGlProgram
    moveGlProgram:retain()
    moveGlProgram:updateUniforms()
    local smoothGlProgram = cc.GLProgram:createWithByteArrays(smoothVertSource, strFragSource)
    self.smoothGlProgram = smoothGlProgram
    smoothGlProgram:retain()
    smoothGlProgram:updateUniforms()
    local endGlProgram = cc.GLProgram:createWithByteArrays(endVertSource, strFragSource)
    self.endGlProgram = endGlProgram
    endGlProgram:retain()
    endGlProgram:updateUniforms()
    self:__registerTouchEvent()
    self.state = RubCardLayer_State_Move

    self:createSprites()

    if self.isTouch then
        self.cardButton = ccui.Button:create("sp_com_dot.png","sp_com_dot.png")
        self.cardButton:setPosition(posX, posY)
        self.cardButton:setVisible(true)
        self.cardButton:setOpacity(0)
        self.cardButton:setScale(600)
        self.cardButton:addTouchEventListener(function(psender,type)
            if type == ccui.TouchEventType.began then
               self:handlerTouchBegin(psender)
            elseif type == ccui.TouchEventType.moved then
               self:handlerTouchMove(psender)
            elseif type == ccui.TouchEventType.ended then
               self:handlerTouchEnd(psender)
            elseif type == ccui.TouchEventType.canceled then
                self:handlerTouchEnd(psender)
            end
        end)
        self.cardButton:setSwallowTouches(true)
        self:addChild(self.cardButton)

        self.touchTipsBtn = ccui.Button:create("picture/btnTips.png","picture/btnTips.png")
        self.touchTipsBtn:setScale(2)
        self.touchTipsBtn:setPosition(posX-g_offsetX,posY)
        self.touchTipsBtn:addTouchEventListener(function(psender,type)
            if type == ccui.TouchEventType.ended then
                self:handleTouchRotate()
            end
        end)
        self:addChild(self.touchTipsBtn)
    end
  
    local sz1 = {self.pokerWidth,self.pokerHeight}
    self.sz1 = sz1
    

    local backRes = GlobalRubCardRes[1]   --背面
    local msh1, nVerts1 = backRes[1],backRes[4]
    local frontRes = GlobalRubCardRes[2]   --正面
    local msh2, nVerts2 = frontRes[1],frontRes[4]
    --if self.pokerWidth ~= 531 and self.pokerHeight ~= 356 then
        msh1, nVerts1 = self:__initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)
        msh2, nVerts2 = self:__initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange2, false)
    --end
    self.vertsNum = nVerts1

    self.ratioVal = 0
    self.radiusVal = sz1[2]/10;

    self.pokerHeight = sz1[2]

    self.offx = self.posX - self.sz1[1]/2
    self.offy = self.posY - self.sz1[2]/2

    --初始化矩阵信息
    self.isRotate90 = false    

    --牌的渲染信息 
    local cardMesh = {{id1, msh1, nVerts1},{id2, msh2, nVerts2} }
    
    self.cardMesh = cardMesh
    -- OpenGL绘制函数
    local function draw(transform, transformUpdated)
        if self.state == RubCardLayer_State_Move then
            self:__drawByMoveProgram(0)
        elseif self.state == RubCardLayer_State_Smooth then
            if self.smoothFrame == nil then
                self.smoothFrame = 1
            end
            if self.smoothFrame <= RubCardLayer_RotationFrame then
                self:__drawByMoveProgram(-RubCardLayer_RotationAnger*self.smoothFrame/RubCardLayer_RotationFrame)
            elseif self.smoothFrame < (RubCardLayer_RotationFrame+RubCardLayer_SmoothFrame) then
                if self.szActFont then
                   local actSP = cc.Sprite:create(self.szActFont)
                   self.frontTexId = actSP:getTexture():getName()
                end
                local scale = (self.smoothFrame - RubCardLayer_RotationFrame)/RubCardLayer_SmoothFrame
                self:__drawBySmoothProgram(math.max(0.01,RubCardLayer_SmoothAnger*(1-scale)))
                
            else
                if self.endCallBack then
                    self.endCallBack()
                    self.endCallBack = nil
                end
                self:__drawByEndProgram()
            end
            self.smoothFrame = self.smoothFrame + 1
        end
    end
    glNode:registerScriptDrawHandler(draw)
end

function GlobalRubCardLayer:setRatioVal(value)
   self.ratioVal = value
   if self.ratioVal > 0.8 then
       self.state = RubCardLayer_State_Smooth
   end
end

function GlobalRubCardLayer:moveToPosition(posx,posy,time) 
     self.moveTime = time or 1
     self:StartToMove(posx,posy)
end

function GlobalRubCardLayer:setScale(value)
   self.scale = value or 1
end



function GlobalRubCardLayer:createSprites()
    --local backFrameSprite =cc.SpriteFrame:create(self.szBack,cc.rect(0,0,356,531))
    local backFrameSprite= cc.Sprite:create(self.szBack)
    self.backFrameSprite = backFrameSprite

    local backSprite = cc.Sprite:create(self.szBack)

    local frontFrameSprite = cc.Sprite:create(self.szFont)--cc.SpriteFrame:create(self.szFont,cc.rect(0,0,356,531))

    self.frontFrameSprite = frontFrameSprite
 
    local pokerSize = backSprite:getContentSize()
    self.pokerWidth = pokerSize.height
    self.pokerHeight = pokerSize.width
    self.pokerActWidth = pokerSize.width
    self.pokerActHeight = pokerSize.height

    self.backTexId = backFrameSprite:getTexture():getName()
    self.frontTexId = frontFrameSprite:getTexture():getName()
end

function GlobalRubCardLayer:getTranslateMat4()
    local translateMat1 = cc.mat4:createIdentity()
    translateMat1 = cc.mat4.createTranslation({x=self.newPosX,y=self.newPosY,z=0})

    local translateMat2 = cc.mat4:createIdentity()
    translateMat2 = cc.mat4.createTranslation({x=-self.newPosX,y=-self.newPosY,z=0})
    return translateMat1,translateMat2
end



--通过角度获取矩阵绕Z轴的旋转
function GlobalRubCardLayer:getRotateZMatByAangel(angle)
    angle = angle or 0
    local mat4 = cc.mat4:createIdentity()
    --cc.mat4.createRotation(cc.vec3(0.0, 0.0, 1.0),angle*math.pi / 180.0, mat4)
    return cc.mat4.createRotation(cc.vec3(0.0, 0.0, 1.0),angle*math.pi / 180.0)
end
--获取缩放矩阵
function GlobalRubCardLayer:getScaleMat()
    local mat4 = cc.mat4:createIdentity()
    self.scale = self.scale or 1
    mat4[1] = self.scale
    mat4[6] = self.scale
    mat4[11] = self.scale
    return mat4 
end
--获取平移矩阵
function GlobalRubCardLayer:getTranslateMat()
    local mat4 = cc.mat4:createIdentity()
    mat4[13] = self.newPosX or 1  --x
    mat4[14] = self.newPosY or 1   --y
    return mat4 
end

function GlobalRubCardLayer:remove()
    local function callBack()
        self:removeFromParent()
    end
    local callFunc = cc.CallFunc:create(callBack)
    local delay = cc.DelayTime:create(0.01)
    local sequence = cc.Sequence:create(delay, callFunc)
    self:runAction(cc.RepeatForever:create(sequence))
end


function GlobalRubCardLayer:__drawByMoveProgram(rotation)
    local glProgram = self.moveGlProgram
    gl.enable(gl.CULL_FACE)
    glProgram:use()
    glProgram:setUniformsForBuiltins()

    for index, v in ipairs(self.cardMesh) do 
        if index == 1 then
            gl._bindTexture(gl.TEXTURE_2D, self.backTexId)
        else
            gl._bindTexture(gl.TEXTURE_2D, self.frontTexId)
        end
        local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
        glProgram:setUniformLocationF32(rotationLc, rotation)
        local ratio = gl.getUniformLocation(glProgram:getProgram(), "ratio")
        glProgram:setUniformLocationF32(ratio, self.ratioVal)
        local radius = gl.getUniformLocation(glProgram:getProgram(), "radius")
        glProgram:setUniformLocationF32(radius, self.radiusVal)
        local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
        glProgram:setUniformLocationF32(offx, self.offx)
        local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
        glProgram:setUniformLocationF32(offy, self.offy)
        local width = gl.getUniformLocation(glProgram:getProgram(), "width")
        glProgram:setUniformLocationF32(width, self.sz1[1])
        local height = gl.getUniformLocation(glProgram:getProgram(), "height")
        glProgram:setUniformLocationF32(height, self.sz1[2])

        local scaleMat =  gl.getUniformLocation(glProgram:getProgram(), "scaleMat")
        local _scalemat = self:getScaleMat()
        glProgram:setUniformLocationWithMatrix4fv(scaleMat, _scalemat,1)

        local isRotate =  gl.getUniformLocation(glProgram:getProgram(), "isRatote")
        local matRotate =  gl.getUniformLocation(glProgram:getProgram(), "matRotate")
        local rotateMat
        if self.isRotate90 == true then
           rotateMat = self:getRotateZMatByAangel(90)
           glProgram:setUniformLocationF32(isRotate, 1.0)
        else
           rotateMat = self:getRotateZMatByAangel(0)
           glProgram:setUniformLocationF32(isRotate, 0.0)
        end
        glProgram:setUniformLocationWithMatrix4fv(matRotate, rotateMat,1)

        local translate1 =  gl.getUniformLocation(glProgram:getProgram(), "translate1")
        local translate2 =  gl.getUniformLocation(glProgram:getProgram(), "translate2")
        local translateMat1,translateMat2 = self:getTranslateMat4()
        glProgram:setUniformLocationWithMatrix4fv(translate1, translateMat1,1)
        glProgram:setUniformLocationWithMatrix4fv(translate2, translateMat2,1)

        self:__drawArrays(v)
    end
    gl.disable(gl.CULL_FACE)
end


function GlobalRubCardLayer:__drawBySmoothProgram(rotation)
    local glProgram = self.smoothGlProgram
    glProgram:use()
    glProgram:setUniformsForBuiltins()

    local v = self.cardMesh[2]
    gl._bindTexture(gl.TEXTURE_2D, self.frontTexId)
    local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
    glProgram:setUniformLocationF32(rotationLc, rotation)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local height = gl.getUniformLocation(glProgram:getProgram(), "height")
    glProgram:setUniformLocationF32(height, self.sz1[2])
    local scaleMat =  gl.getUniformLocation(glProgram:getProgram(), "scaleMat")
    local _scalemat = self:getScaleMat()
    glProgram:setUniformLocationWithMatrix4fv(scaleMat, _scalemat,1)
    local matRotate =  gl.getUniformLocation(glProgram:getProgram(), "matRotate")
    local rotateMat
    if self.isRotate90 == true then
       rotateMat = self:getRotateZMatByAangel(90)
    else
       rotateMat = self:getRotateZMatByAangel(0)
    end
    glProgram:setUniformLocationWithMatrix4fv(matRotate, rotateMat,1)

    local translate1 =  gl.getUniformLocation(glProgram:getProgram(), "translate1")
    local translate2 =  gl.getUniformLocation(glProgram:getProgram(), "translate2")
    local translateMat1,translateMat2 = self:getTranslateMat4()
    glProgram:setUniformLocationWithMatrix4fv(translate1, translateMat1,1)
    glProgram:setUniformLocationWithMatrix4fv(translate2, translateMat2,1)

    self:__drawArrays(v)
end

function GlobalRubCardLayer:__drawByEndProgram()
    local glProgram = self.endGlProgram
    glProgram:use()
    glProgram:setUniformsForBuiltins()
    local v = self.cardMesh[2]
    gl._bindTexture(gl.TEXTURE_2D, self.frontTexId)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local scaleMat =  gl.getUniformLocation(glProgram:getProgram(), "scaleMat")
    local _scalemat = self:getScaleMat()
    glProgram:setUniformLocationWithMatrix4fv(scaleMat, _scalemat,1)
    local matRotate =  gl.getUniformLocation(glProgram:getProgram(), "matRotate")
    local rotateMat
    if self.isRotate90 == true then
       rotateMat = self:getRotateZMatByAangel(90)
    else
       rotateMat = self:getRotateZMatByAangel(0)
    end
    glProgram:setUniformLocationWithMatrix4fv(matRotate, rotateMat,1)

    local translate1 =  gl.getUniformLocation(glProgram:getProgram(), "translate1")
    local translate2 =  gl.getUniformLocation(glProgram:getProgram(), "translate2")
    local translateMat1,translateMat2 = self:getTranslateMat4()
    glProgram:setUniformLocationWithMatrix4fv(translate1, translateMat1,1)
    glProgram:setUniformLocationWithMatrix4fv(translate2, translateMat2,1)

    self:__drawArrays(v)
end

function GlobalRubCardLayer:__drawArrays(v)
    gl.glEnableVertexAttribs(bit:_or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
    gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1])
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION,2,gl.FLOAT,false,0,0)
    gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2])
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD,3,gl.FLOAT,false,0,0)
    gl.drawArrays(gl.TRIANGLES, 0, self.vertsNum/2)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
end

function GlobalRubCardLayer:handlerTouchBegin(pSender)
    if self.schedulerID~=nil then
       cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
       self.schedulerID=nil
    end
    self.touchBeginPos = pSender:getTouchBeganPosition()
end
function GlobalRubCardLayer:handlerTouchMove(pSender)
    local touchMovePos = pSender:getTouchMovePosition()
    if self.touchBeginPos.y > touchMovePos.y and self.ratioVal == 0 then 
        return 
    end   --向上滑动
    local height = 600
    if self.isRotate90 then
        height = 835
    end
    local offsetY = math.abs(self.touchBeginPos.y - self.touchBeginPos.y)
    self.ratioVal = math.abs(touchMovePos.y-offsetY)/height
    self.ratioVal = math.max(0, self.ratioVal)
    self.ratioVal = math.min(1.3, self.ratioVal)
    if self.touchTipsBtn then
       self.touchTipsBtn:setOpacity(0)
    end

    --[[local buttonPosX,buttonPosY = pSender:getPosition()
    local height = self.pokerActWidth
    if self.isRotate90 then
        height = self.pokerActHeight
    end
    if self.touchBeginPos.y < buttonPosY and ( math.abs(self.touchBeginPos.y-buttonPosY)>= height*0.35) then
        local offsetY = math.abs(buttonPosY - height/2)
        self.ratioVal = (touchMovePos.y-offsetY)/height
        self.ratioVal = math.max(0, self.ratioVal)
        self.ratioVal = math.min(1.3, self.ratioVal)
        if self.touchTipsBtn then
           self.touchTipsBtn:setOpacity(0)
        end
    end]]
end
function GlobalRubCardLayer:handlerTouchEnd(pSender)
       if self.ratioVal >= 0.8 then
           self.state = RubCardLayer_State_Smooth
       else
       	    local function endfunc()
       	    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
       	    	self.schedulerID=nil
       	    end
            self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,function(dt)
       	    	self.ratioVal = self.ratioVal - 0.1
       	    	if self.ratioVal < 0 then
       	    		self.ratioVal = 0
       	    	end
       	    	if self.ratioVal == 0 and self.schedulerID~=nil then
               		endfunc()
       	    	end
                   
           end),0.02,false)
       end  
end

function GlobalRubCardLayer:handleTouchRotate()
    if self.isRotate90 == true then
       self.isRotate90 = false
       self.cardButton:setRotation(90)
    else
       self.isRotate90 = true
       self.cardButton:setRotation(0)
    end
end

function GlobalRubCardLayer:__registerTouchEvent()
    local function onNodeEvent(event)
        if "exit" == event then
           --[[ gl._deleteBuffer(self.cardMesh[1][2][1].buffer_id)
            gl._deleteBuffer(self.cardMesh[1][2][2].buffer_id)
            gl._deleteBuffer(self.cardMesh[2][2][1].buffer_id)
            gl._deleteBuffer(self.cardMesh[2][2][2].buffer_id)]]
            self.moveGlProgram:release()
            self.smoothGlProgram:release()
            self.endGlProgram:release()

    		if self.schedulerID~=nil then
        		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        		self.schedulerID=nil
    		end
            self:StopMoveTimeID()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    local function touchBegin(touch, event)
    	--[[if self.schedulerID~=nil then
        	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        	self.schedulerID=nil
    	end
        local pos = touch:getLocation()
        local tmppos =self.cardTemp:convertToNodeSpace(pos)
        local cardRect = cc.rect(0, 0, self.cardTemp:getContentSize().width, self.cardTemp:getContentSize().height)
        if true == cc.rectContainsPoint(cardRect, tmppos) then
            self.isTouchCard = true
            self.touchPos = pos
        else
            self.isTouchCard = false
        end]]
        return true
    end
    local function touchMove(touch, event)
        --[[if self.isTouchCard == true then
           local location = touch:getLocation()
           self.ratioVal = (location.y-self.offy)/self.pokerHeight
           self.ratioVal = math.max(0, self.ratioVal)
           self.ratioVal = math.min(1, self.ratioVal)
           if self.cardTemp then
               local offsetx = location.x - self.touchPos.x
               local offsety = location.y - self.touchPos.y
               self.touchPos = location
               local curPosx,curPosY = self.cardTemp:getPosition()
               self.cardTemp:setPosition(curPosx+offsetx,curPosY+offsety)
           end
        else
           self.ratioVal = 0
        end]]
        return true
    end
    local function touchEnd(touch, event)
        if self.ratioVal >= 0.8 then
            self.state = RubCardLayer_State_Smooth
            if self.szActFont then
                local actSP = cc.Sprite:create(self.szActFont)
                self.frontTexId = actSP:getTexture():getName()
            end
        else
        	local function endfunc()
        		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        		self.schedulerID=nil
        	end
    		self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,function(dt)
        		self.ratioVal = self.ratioVal - 0.1
        		if self.ratioVal < 0 then
        			self.ratioVal = 0
        		end
        		if self.ratioVal == 0 and self.schedulerID~=nil then
            		endfunc()
        		end
                
    		end),0.02,false)
        end
        return true
    end
   --[[ local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)]]
end

--分割宽
function GlobalRubCardLayer:__initCardVertex(size, texRange, isBack)
    local frameSprite = self.frontFrameSprite
    if isBack then
        frameSprite = self.backFrameSprite
    end
    local rect = frameSprite:getTextureRect()
    local allSize = frameSprite:getTexture():getContentSize()
    local allWidth = allSize.width
    local allHeight = allSize.height

    local nDiv = 20 --将宽分成100份
    
    local verts = {} --位置坐标
    local texs = {} --纹理坐标

    local nDivX = 30 --将宽分成30份
    local nDivY = 20 --将宽分成20份

    local dh = size.height/nDivY
    local dw = size.width/nDivX

    local nPerW = 1/allWidth
    local nPerH = 1/allHeight 

    for c = 1 ,nDivX do
        for r = 1, nDivY do 
            local x, y = (c-1)*dw, (r-1)*dh
            local quad = {}
            if isBack then
                quad = {x, y, x+dw, y, x, y+dh, x+dw, y, x+dw, y+dh, x, y+dh}
            else
                quad = {x, y, x, y+dh, x+dw, y, x+dw, y, x, y+dh, x+dw, y+dh}
            end
            for i=1,6 do
                local quadX = quad[i*2-1]
                local quadY = quad[i*2]
                local numX;
                local numY ; 
                local numX2 ;

                numX =  ((rect.x+allWidth-quadY)/allWidth)
                numY =  ((rect.y+quadX)/allHeight)
                numX2 = ((rect.x+quadY)/allWidth)

                table.insert(texs, math.max(0,numX));
                table.insert(texs, math.max(0,numY));
                table.insert(texs, math.max(0,numX2));
            end
            for _, v in ipairs(quad) do table.insert(verts, v) end
        end
    end

    local res = {}
    local tmp = {verts, texs}
    for _, v in ipairs(tmp) do 
        local buffid = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
        gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
        gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        table.insert(res, buffid)
    end
    self.vertsNum = #verts
    return res, #verts
end

--移动到哪里
function GlobalRubCardLayer:StartToMove(posx,posy)
   self:StopMoveTimeID()  
   local speed = self.moveTime or 1  ---移动的时间
   local startx,starty = self.newPosX,self.newPosY
   local stepx = (posx - startx)/speed
   local stepy = (posy - starty)/speed
   self._moveTimeID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
       self.newPosX = self.newPosX+stepx
       self.newPosY = self.newPosY+stepy
       if math.abs(self.newPosX - posx) <0.0005 and math.abs(self.newPosX - posx) <0.0005 then
           self:StopMoveTimeID()
       end
   end,0.01,false)
end

function GlobalRubCardLayer:StopMoveTimeID()
    if self._moveTimeID ~= nil and self._moveTimeID >0 then
       cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._moveTimeID)
       self._moveTimeID=nil
    end  
end

return GlobalRubCardLayer
