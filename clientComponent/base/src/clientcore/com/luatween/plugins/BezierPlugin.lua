--
-- 贝塞尔曲线
-- Author: senji
-- Date: 2014-03-03 00:54:46
--
BezierPlugin = class_quick("BezierPlugin")
BezierPlugin.API = 1.0;
BezierPlugin._RAD2DEG = 180 / math.pi;

function BezierPlugin:ctor()
    self._target = nil;
    self._orientData = nil;
    self._future = {};
    self._beziers = nil;
    ClassUtil.extends(self, TweenPlugin);
    self.propName = "bezier";
    self.overwriteProps = {};
end

--override
function BezierPlugin:onInitTween(target, value, tween)
    if type(value) ~= "table" then
        return false;
    end

    self:init(tween, value, false);
    return true;
end

function BezierPlugin:init(tween, beziers, through)
    self._target = tween.target;
    local enumerables = nil;
    if tween.vars.isTV == true then
        enumerables = tween.vars.exposedVars;
    else
        enumerables = tween.vars;
    end

    if enumerables.orientToBezier == true then
        self._orientData = { { "x", "y", "rotation", 0, 0.01 } };
        self._orient = true;
    elseif type(enumerables.orientToBezier) == "table" then
        self._orientData = enumerables.orientToBezier;
        self._orient = true;
    end

    local props = {};
    local i = 0;
    local killVarsLookup = nil;
    for i = 1, #beziers do
        for p, v in pairs(beziers[i]) do
            local curTValue = LuaTweenConfig.getTargetValue(tween.target, p);
            local curBValue = beziers[i][p];
            if props[p] == nil then
                props[p] = { curTValue };
            end
            if type(beziers[i][p]) == "number" then
                table.insert(props[p], curBValue);
            else
                table.insert(props[p], curTValue + curBValue);
            end
        end
    end

    for p, v in pairs(props) do
        table.insert(self.overwriteProps, p);
        if enumerables[p] ~= nil then
            local curTValue = LuaTweenConfig.getTargetValue(tween.target, p);
            if typeof(enumerables[p]) == "number" then
                table.insert(props[p], enumerables[p]);
            else
                table.insert(props[p], curTValue + enumerables[p]);
            end
            killVarsLookup = {};
            killVarsLookup[p] = true;
            tween.killVars(killVarsLookup, false);
            enumerables[p] = nil;
        end
    end

    self._beziers = BezierPlugin.parseBeziers(props, through);
end

-- static 
function BezierPlugin.parseBeziers(props, through)
    local i = 0;
    local a = nil;
    local b = nil;
    local p = nil;
    local all = {};
    if through then
        for p, a in pairs(props) do
            b = {};
            all[p] = b;
            if #a > 2 then
                b[#b + 1] = { a[1], a[2] - ((a[3] - a[1]) / 4), a[2] };
                for i = 2, #a - 1 do
                    b[#b + 1] = { a[i], a[i] + (a[i] - b[i - 1][2]), a[i + 1] };
                end
            else
                b[#b + 1] = { a[1], (a[1] + a[2]) / 2, a[2] };
            end
        end
    else
        for p, a in pairs(props) do
            b = {};
            all[p] = b;
            local len = #a;
            if len > 3 then
                b[#b + 1] = { a[1], a[2], (a[2] + a[3]) / 2 };
                for i = 3, #b - 2 do
                    b[#b] = { b[i - 2][3], a[i], (a[i] + a[i + 1]) / 2 };
                end
            elseif len == 3 then
                b[#b + 1] = { a[1], a[2], a[3] };
            elseif len == 2 then
                b[#b + 1] = { a[1], (a[1] + a[2]) * .5, a[2] };
            end
        end
    end

    return all;
end

-- override 
function BezierPlugin:killProps(lookup)
    for p, v in pairs(self._beziers) do
        if lookup[p] ~= nil then
            self._beziers[p] = nil;
        end
    end

    TweenPlugin.killProps(self, lookup);
end

-- override
function BezierPlugin:setChangeFactor(n)
    local i = 0;
    local p = nil;
    local b = nil;
    local t = 0;
    local segments = 0;
    local val = 0;

    self._changeFactor = n;
    if n == 1 then
        for p, v in pairs(self._beziers) do
            i = #(self._beziers[p]);
            LuaTweenConfig.setTargetValue(self._target, p, self._beziers[p][i][3])
        end
    else
        for p, v in pairs(self._beziers) do
            segments = #(self._beziers[p]);
            if n < 0 then
                i = 1;
            elseif n >= 1 then
                i = segments;
            else
                i = parseInt(segments * n) + 1;
            end
            t = (n - ((i - 1) * (1 / segments))) * segments;
            b = self._beziers[p][i];
            local tempVal = 0;
            if self.round then
                val = b[1] + t * (2 * (1 - t) * (b[2] - b[1]) + t * (b[3] - b[1]));
                tempVal = parseInt(val + 0.5);
                if val <= 0 then
                    tempVal = parseInt(val - 0.5);
                end
            else
                tempVal = b[1] + t * (2 * (1 - t) * (b[2] - b[1]) + t * (b[3] - b[1]));
            end
            LuaTweenConfig.setTargetValue(self._target, p, tempVal)
        end
    end
    if self._orient then
        i = #self._orientData;
        local curVals = {};
        local dx = 0;
        local dy = 0;
        local cotb = nil;
        local toAdd = 0;
        while i > 0 do
            cotb = self._orientData[i];
            curVals[cotb[1]] = LuaTweenConfig.getTargetValue(self._target, cotb[1]);
            curVals[cotb[2]] = LuaTweenConfig.getTargetValue(self._target, cotb[2]);
            i = i - 1;
        end

        local oldTarget = self._target;
        local oldRound = self.round;
        self._target = self._future;
        self.round = false;
        self._orient = false;
        i = #self._orientData;
        while i > 0 do
            cotb = self._orientData[i];
            local tempCotb = cotb[5] or 0;
            if tempCotb == 0 then
                tempCotb = 0.01;
            end
            self:setChangeFactor(n + tempCotb);
            toAdd = cotb[4] or 0;
            dx = LuaTweenConfig.getTargetValue(self._future, cotb[1]) - curVals[cotb[1]];
            dy = LuaTweenConfig.getTargetValue(self._future, cotb[2]) - curVals[cotb[2]];
            LuaTweenConfig.setTargetValue(oldTarget, cotb[3], (2 * math.pi - math.atan2(dy, dx)) * BezierPlugin._RAD2DEG + toAdd);
            i = i - 1;
        end
        self._target = oldTarget;
        self.round = oldRound
        self._orient = true;
    end
end
