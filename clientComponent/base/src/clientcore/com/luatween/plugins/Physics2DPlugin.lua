--
-- Author: senji
-- Date: 2014-03-03 16:57:24
--
Physics2DPlugin = class_quick("Physics2DPlugin")
Physics2DPlugin.API = 1.0;
Physics2DPlugin._DEG2RAD = math.pi / 180;

function Physics2DPlugin:ctor()
    self._tween = nil;
    self._target = nil;
    self._x = 0;
    self._y = 0;
    self._skipX = false;
    self._skipY = false;
    self._friction = 1;
    self._step = 0;
    self._stepsPerTimeUnit = 30;

    ClassUtil.extends(self, TweenPlugin);
    self.propName = "physics2D";
    self.overwriteProps = { "x", "y" };
end

--override
function Physics2DPlugin:onInitTween(target, value, tween)
    self._target = target;
    self._tween = tween;
    self._step = 0;
    local tl = self._tween.timeline;
    while tl.timeline do
        tl = tl.timeline;
    end

    if tl == TweenLite.rootFramesTimeline then
        self._stepsPerTimeUnit = 1;
    end

    local angle = value.angle or 0;
    local velocity = value.velocity or 0;
    local acceleration = value.acceleration or 0;
    local aAngle = angle;
    if value.accelerationAngle or value.accelerationAngle == 0 then
        aAngle = value.accelerationAngle;
    end

    if value.gravity ~= nil and value.gravity ~= 0 then
        acceleration = value.gravity;
        aAngle = 90;
    end

    angle = angle * Physics2DPlugin._DEG2RAD;
    aAngle = aAngle * Physics2DPlugin._DEG2RAD;
    if value.friction ~= nil and value.friction ~= 0 then
        self._friction = 1 - value.friction;
    end

    local targetX = LuaTweenConfig.getTargetValue(self._target, "x");
    local targetY = LuaTweenConfig.getTargetValue(self._target, "y");
    self._x = Physics2DProp.new(targetX, math.cos(angle) * velocity, math.cos(aAngle) * acceleration, self._stepsPerTimeUnit);
    self._y = Physics2DProp.new(targetY, math.sin(angle) * velocity, math.sin(aAngle) * acceleration, self._stepsPerTimeUnit);
    return true;
end

--override
function Physics2DPlugin:killProps(lookup)
    if lookup["x"] ~= nil then
        self._skipX = true;
    end
    if lookup["y"] ~= nil then
        self._skipY = true;
    end
    TweenPlugin.killProps(self, lookup);
end


--override
function Physics2DPlugin:setChangeFactor(n)
    local time = self._tween.cachedTime;
    local x = 0;
    local y = 0;

    if self._friction == 1 then
        local tt = time * time * .5;
        x = self._x.start + ((self._x.velocity * time) + (self._x.acceleration * tt));
        y = self._y.start + ((self._y.velocity * time) + (self._y.acceleration * tt));
    else
        local steps = parseInt(time * self._stepsPerTimeUnit) - self._step;
        local remainder = (time * self._stepsPerTimeUnit) % 1;
        local j = 0;
        if steps >= 0 then
            j = steps;
            while j > 0 do
                self._x.v = self._x.v + self._x.a;
                self._y.v = self._y.v + self._y.a;
                self._x.v = self._x.v * self._friction;
                self._y.v = self._y.v * self._friction;
                self._x.value = self._x.value + self._x.v;
                self._y.value = self._y.value + self._y.v;
                j = j - 1;
            end
        else
            j = -steps;
            while j > 0 do
                self._x.value = self._x.value - self._x.v;
                self._y.value = self._y.value - self._y.v;
                self._x.v = self._x.v / self._friction;
                self._y.v = self._y.v / self._friction;
                self._x.v = self._x.v - self._x.a;
                self._y.v = self._y.v - self._y.a;
            end
        end

        x = self._x.value + (self._x.v * remainder);
        y = self._y.value + (self._y.v * remainder);
        self._step = self._step + steps;
    end

    if self.round then
        if x > 0 then
            x = parseInt(x + .5);
        else
            x = parseInt(x - .5);
        end

        if y > 0 then
            y = parseInt(y + .5);
        else
            y = parseInt(y - .5);
        end
    end

    if not self._skipX then
        LuaTweenConfig.setTargetValue(self._target, "x", x);
    end
    if not self._skipY then
        LuaTweenConfig.setTargetValue(self._target, "y", y);
    end
end

Physics2DProp = class_quick("Physics2DProp")
function Physics2DProp:ctor(start, velocity, acceleration, stepsPerTimeUnit)
    self.start = start;
    self.value = start;
    self.velocity = velocity;
    self.v = self.velocity / stepsPerTimeUnit;
    if acceleration ~= nil then
        self.acceleration = acceleration;
        self.a = self.acceleration / (stepsPerTimeUnit * stepsPerTimeUnit);
    else
        self.a = 0;
        self.acceleration = 0;
    end
end