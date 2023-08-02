--
-- Author: lex
-- Date: 2014-09-13 09:52:24

ShaderUtil = {}

ShaderUtil._shaders =
{
    ["GRAY"] = { "gameres/shader/Gray.vsh", "gameres/shader/Gray.fsh" },
    ["BLUR"] = { "gameres/shader/Blur.vsh", "gameres/shader/Blur.fsh" },
};

ShaderUtil._shaders3D = {
    ["GREYSCALE"] = { "gameres/shader3D/noMvp.vert", "gameres/shader3D/greyScale.fsh" },
    ["OUTLINE"] = { "gameres/shader3D/OutLine.vert", "gameres/shader3D/OutLine.frag" },
};

ShaderUtil._shaderCache = {};
ShaderUtil._shaderCache3D = {};


function ShaderUtil.addShaders(shaders)
    for k, v in pairs(shaders) do
        ShaderUtil._shaders[k] = v
    end
end


function ShaderUtil.getShader(name)
    local shaderConfig = ShaderUtil._shaders[name];
    local result = ShaderUtil._shaderCache[name]
    if shaderConfig and not result then
        result = cc.GLProgram:createWithFilenames(shaderConfig[1], shaderConfig[2]);
        result:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);
        result:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR);
        result:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD);

        result = cc.GLProgramState:getOrCreateWithGLProgram(result);
        ShaderUtil._shaderCache[name] = result;
    end
    return result
end

function ShaderUtil.getShader3D(name)
    local files = ShaderUtil._shaders3D[name]
    if files and not ShaderUtil._shaderCache3D[name] then
        echo("ShaderUtil.getShader3D", name)
        ShaderUtil._shaderCache3D[name] = cc.GLProgram:new()
        ShaderUtil._shaderCache3D[name]:initWithFilenames(files[1], files[2])
        ShaderUtil._shaderCache3D[name]:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);
        ShaderUtil._shaderCache3D[name]:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR);
        ShaderUtil._shaderCache3D[name]:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD);
    end

    return ShaderUtil._shaderCache3D[name]
end

function ShaderUtil.setShaderByName(pWidget, shanderName)
    if ShaderUtil._shaders[shanderName] then
        ShaderUtil.setShader(pWidget, ShaderUtil.getShader(shanderName));
    end
end

function ShaderUtil.setShader(node, pShader)
    if not node or not pShader then
        return;
    end

    if node.setGLProgramState then
        node:setGLProgramState(pShader);
    end
    for i, v in ipairs(node:getChildren()) do
        ShaderUtil.setShader(v, pShader)
    end
    -- if node.getProtectedChildren then
    -- 	for i,v in ipairs(node:getProtectedChildren()) do
    -- 		ShaderUtil.setShader(v, pShader)
    -- 	end
    -- end
end

-- name string
-- value number or table {xxx, yyy, zzz}
function ShaderUtil.setParameter(pState, name, value)
    --echo("ShaderUtil.setParameter", pShader, name, value)
    --local pState = cc.GLProgramState:getOrCreateWithGLProgram(pShader);
    --if not pState then
    --	return;
    --end

    if type(value) == "number" then
        pState:setUniformFloat(name, value);
    elseif type(value) == "table" then
        if #value == 2 then
            pState:setUniformVec2(name, { x = value[1], y = value[2] });
        elseif #value == 3 then
            pState:setUniformVec3(name, { x = value[1], y = value[2], z = value[3] });
        elseif #value == 4 then
            pState:setUniformVec4(name, { x = value[1], y = value[2], z = value[3], w = value[4] });
        end
    end
end

function ShaderUtil.resetShader(pWidget)
    local result = cc.ShaderCache:getInstance():getProgram("ShaderPositionTextureColor_noMVP");
    result = cc.GLProgramState:getOrCreateWithGLProgram(result);
    ShaderUtil.setShader(pWidget, result);
end

-- 变灰
function ShaderUtil.gray(pWidget)
    ShaderUtil.setShaderByName(pWidget, "GRAY")
end

-- 变暗
function ShaderUtil.dark(pWidget)
    ShaderUtil.setShaderByName(pWidget, "DARK")
end
