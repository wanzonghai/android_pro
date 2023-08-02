--
-- 所有缓动公式的集合
-- Author: senji
-- Date: 2014-02-11 16:31:19
--

Ease = {};
Ease._HALF_PI = math.pi * 0.5;
Ease._2PI = math.pi * 2;

Sine = {};

function Sine.easeIn(t, b, c, d)
    return -c * math.cos(t / d * Ease._HALF_PI) + c + b;
end

function Sine.easeOut(t, b, c, d)
    return c * math.sin(t / d * Ease._HALF_PI) + b;
end

function Sine.easeInOut(t, b, c, d)
    return -c * 0.5 * (math.cos(math.pi * t / d) - 1) + b;
end


Back = {};

function Back.easeIn(t, b, c, d, s)
    s = s or 1.70158;
    t = t / d;
    return c * t * t * ((s + 1) * t - s) + b;
end

function Back.easeOut(t, b, c, d, s)
    s = s or 1.70158;
    t = t / d - 1;
    return c * (t * t * ((s + 1) * t + s) + 1) + b;
end

function Back.easeInOut(t, b, c, d, s)
    s = s or 1.70158;
    t = t / (d * 0.5)
    if t < 1 then
        s = s * 1.525;
        return c * 0.5 * t * t * ((s + 1) * t - s) + b;
    else
        t = t - 2;
        s = s * 1.525;
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b;
    end
end


Bounce = {};

function Bounce.easeIn(t, b, c, d)
    return c - Bounce.easeOut(d - t, 0, c, d) + b;
end

function Bounce.easeOut(t, b, c, d)
    t = t / d
    if t < 1 / 2.75 then
        return c * (7.5625 * t * t) + b;
    elseif t < 2 / 2.75 then
        t = t - (1.5 / 2.75);
        return c * (7.5625 * t * t + .75) + b;
    elseif t < 2.5 / 2.75 then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + .9375) + b;
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + .984375) + b;
    end
end

function Bounce.easeInOut(t, b, c, d)
    if t < d * 0.5 then
        return Bounce.easeIn(t * 2, 0, c, d) * .5 + b;
    else
        return Bounce.easeOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
    end
end


Circ = {};

function Circ.easeIn(t, b, c, d)
    t = t / d;
    return -c * (math.sqrt(1 - t * t) - 1) + b;
end

function Circ.easeOut(t, b, c, d)
    t = t / d - 1;
    return c * math.sqrt(1 - t * t) + b;
end

function Circ.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if t < 1 then
        return -c * 0.5 * (math.sqrt(1 - t * t) - 1) + b;
    else
        t = t - 2;
        return c * 0.5 * (math.sqrt(1 - t * t) + 1) + b;
    end
end


Cubic = {};
Cubic.power = 2;

function Cubic.easeIn(t, b, c, d)
    t = t / d;
    return c * t * t * t + b
end

function Cubic.easeOut(t, b, c, d)
    t = t / d - 1;
    return c * (t * t * t + 1) + b
end

function Cubic.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if t < 1 then
        return c * 0.5 * t * t * t + b;
    else
        t = t - 2;
        return c * 0.5 * (t * t * t + 2) + b;
    end
end

Elastic = {};

function Elastic.easeIn(t, b, c, d, a, p)
    a = a or 0;
    p = p or 0;

    local s = 0;
    if t == 0 then
        return b;
    end
    t = t / d;
    if t == 1 then
        return b + c;
    end
    if p == 0 then
        p = d * .3;
    end
    if a ~= 0 or (c > 0 and a < c) or (c < 0 and a < -c) then
        a = c;
        s = p / 4;
    else
        s = p / Ease._2PI * math.asin(c / a);
    end
    t = t - 1;
    return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * Ease._2PI / p)) + b;
end

function Elastic.easeOut(t, b, c, d, a, p)
    a = a or 0;
    p = p or 0;

    local s = 0;
    if (t == 0) then
        return b;
    end
    t = t / d
    if t == 1 then
        return b + c;
    end
    if p == 0 then
        p = d * .3;
    end
    if a ~= 0 or (c > 0 and a < c) or (c < 0 and a < -c) then
        a = c;
        s = p / 4;
    else
        s = p / Ease._2PI * math.asin(c / a);
    end
    return (a * math.pow(2, -10 * t) * math.sin((t * d - s) * Ease._2PI / p) + c + b);
end

function Elastic.easeInOut(t, b, c, d, a, p)
    a = a or 0;
    p = p or 0;

    local s = 0;
    if (t == 0) then
        return b;
    end
    t = t / (d * 0.5);
    if t == 2 then
        return b + c;
    end
    if p == 0 then
        p = d * (.3 * 1.5);
    end
    if a ~= 0 or (c > 0 and a < c) or (c < 0 and a < -c) then
        a = c;
        s = p / 4;
    else
        s = p / Ease._2PI * math.asin(c / a);
    end
    if t < 1 then
        t = t - 1
        return -0.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * Ease._2PI / p)) + b;
    else
        t = t - 1;
        return a * math.pow(2, -10 * t) * math.sin((t * d - s) * Ease._2PI / p) * 0.5 + c + b;
    end
end

Expo = {};

function Expo.easeIn(t, b, c, d)
    if t == 0 then
        return b
    else
        return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001;
    end
end

function Expo.easeOut(t, b, c, d)
    if t == d then
        return b + c;
    else
        return c * (-math.pow(2, -10 * t / d) + 1) + b;
    end
end

function Expo.easeInOut(t, b, c, d)
    if t == 0 then
        return b;
    end
    if t == d then
        return b + c;
    end
    t = t / (d * 0.5);
    if t < 1 then
        return c * 0.5 * math.pow(2, 10 * (t - 1)) + b;
    else
        t = t - 1;
        return c * 0.5 * (-math.pow(2, -10 * t) + 2) + b;
    end
end

Linear = {};
Linear.power = 0;

function Linear.easeNone(t, b, c, d)
    return c * t / d + b;
end

function Linear.easeIn(t, b, c, d)
    return c * t / d + b;
end

function Linear.easeOut(t, b, c, d)
    return c * t / d + b;
end

function Linear.easeInOut(t, b, c, d)
    return c * t / d + b;
end

Quad = {};
Quad.power = 1;

function Quad.easeIn(t, b, c, d)
    t = t / d;
    return c * t * t + b;
end

function Quad.easeOut(t, b, c, d)
    t = t / d;
    return -c * t * (t - 2) + b;
end

function Quad.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if t < 1 then
        return c * 0.5 * t * t + b;
    else
        t = t - 1;
        return -c * 0.5 * (t * (t - 2) - 1) + b;
    end
end

Quart = {};
Quart.power = 3;

function Quart.easeIn(t, b, c, d)
    t = t / d;
    return c * t * t * t * t + b;
end

function Quart.easeOut(t, b, c, d)
    t = t / d - 1;
    return -c * (t * t * t * t - 1) + b;
end

function Quart.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if (t < 1) then
        return c * 0.5 * t * t * t * t + b;
    else
        t = t - 2;
        return -c * 0.5 * (t * t * t * t - 2) + b;
    end
end

Quint = {};
Quint.powert = 4;

function Quint.easeIn(t, b, c, d)
    t = t / d;
    return c * t * t * t * t * t + b;
end

function Quint.easeOut(t, b, c, d)
    t = t / d - 1;
    return c * (t * t * t * t * t + 1) + b;
end

function Quint.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if (t < 1) then
        return c * 0.5 * t * t * t * t * t + b;
    else
        t = t - 2;
        return c * 0.5 * (t * t * t * t * t + 2) + b;
    end
end

Strong = {};
Strong.power = 4;

function Strong.easeIn(t, b, c, d)
    t = t / d
    return c * t * t * t * t * t + b;
end

function Strong.easeOut(t, b, c, d)
    t = t / d - 1;
    return c * (t * t * t * t * t + 1) + b
end

function Strong.easeInOut(t, b, c, d)
    t = t / (d * 0.5);
    if t < 1 then
        return c * 0.5 * t * t * t * t * t + b;
    else
        t = t - 2;
        return c * 0.5 * (t * t * t * t * t + 2) + b;
    end
end



