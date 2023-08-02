--
--	自定义ease 
--  自定义demo地址https://greensock.com/customease-as
-- Author: senji
-- Date: 2017-04-23 03:36:17
--
CustomEase = class_quick("CustomEase")

CustomEase.VERSION = 1.01;
local _all ={}; --keeps track of all CustomEase instances.

function CustomEase.create(name, segments)
	local b = CustomEase.new(name, segments);
	return handler(b, b.ease);
end

function CustomEase.byName(name)
	return handler(_all[name], _all[name].ease);
end

function CustomEase:ctor(name, segments)
	self._name = name;
	self._segments = {};
	local l = #segments;
	for i=1,l do
		self._segments[#self._segments + 1] = {s = segments[i].s, cp = segments[i].cp, e = segments[i].e};
	end
	_all[name] = self;
end

function CustomEase:ease(time, start, change, duration)
	local factor = time / duration;
	local qty = #self._segments
	local t = nil; 
	local s = nil;
	local i = parseInt(qty * factor);
	t = (factor - (i * (1 / qty))) * qty;
	s = self._segments[i + 1];
	return start + change * (s.s + t * (2 * (1 - t) * (s.cp - s.s) + t * (s.e - s.s)));
end

function CustomEase:destroy()
	self._segments = nil;
	_all[self._name] = nil;
end