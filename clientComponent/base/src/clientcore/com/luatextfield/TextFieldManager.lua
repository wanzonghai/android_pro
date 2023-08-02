--
-- Author: senji
-- Date: 2016-06-15 09:19:33
--
local TextFieldManager = class_quick("TextFieldManager")

function TextFieldManager:ctor()
	ClassUtil.extends(self, TickBase);

	self._checkRenderInNextFrameDic = {};
	self._checkRenderLenNextFrame = 0;

	self._checkRenderDicOnShow = {};
	self._checkRenderLenOnShow = 0;
	self._elapsedTime = 0;
	self._checkRenderInDisplayIntervalInS = 1 / 8;
end

-- isRenderOnShowOrNextTick true只有在显示时才进行渲染，false 为下一帧进行渲染（因为有可能一帧内会set很多次文本，所以最终只会以渲染时才会决定最红渲染内容）
function TextFieldManager:put(tf, isRenderOnShowOrNextTick)
	if isRenderOnShowOrNextTick then
		if DisplayUtil.isInDisplayList(tf) then
			tf:render()
			self:remove(tf);
		else
			local isContains = self._checkRenderDicOnShow[tf];
			if not isContains then
				self._checkRenderDicOnShow[tf] = true;
				self._checkRenderLenOnShow = self._checkRenderLenOnShow + 1;
			end
		end
	else
		if not self._checkRenderInNextFrameDic[tf] then
			self._checkRenderInNextFrameDic[tf] = true;
			self._checkRenderLenNextFrame = self._checkRenderLenNextFrame + 1
		end
	end

	if (self._checkRenderLenOnShow > 0 or self._checkRenderLenNextFrame > 0) and not self:getIsTicking() then
		self:startTick(8);
	end
end

function TextFieldManager:checkStopTick()
	if self._checkRenderLenOnShow <= 0 and self._checkRenderLenNextFrame <= 0 then
		self:stopTick();
		self._checkRenderLenOnShow = 0;
		self._checkRenderLenNextFrame = 0;
	end
end

function TextFieldManager:remove(tf)
	if self._checkRenderDicOnShow[tf] then
		self._checkRenderDicOnShow[tf] = nil;
		self._checkRenderLenOnShow = self._checkRenderLenOnShow - 1;
	end

	if self._checkRenderInNextFrameDic[tf] then
		self._checkRenderInNextFrameDic[tf] = nil;
		self._checkRenderLenNextFrame = self._checkRenderLenNextFrame - 1;
	end

	self:checkStopTick()
end

function TextFieldManager:tick(t)
	self._elapsedTime = self._elapsedTime + t;
	if self._checkRenderLenNextFrame > 0 then
		for k,v in pairs(self._checkRenderInNextFrameDic) do
			k:render(true)
		end
		self._checkRenderInNextFrameDic = {}
		self._checkRenderLenNextFrame = 0;
	end


	if self._elapsedTime >= self._checkRenderInDisplayIntervalInS then
		self._elapsedTime = 0
		if self._checkRenderLenOnShow > 0 then
			local removeArr = nil;
			for tf, b in pairs(self._checkRenderDicOnShow) do
				if DisplayUtil.isInDisplayList(tf) then
					tf:render();
					if not removeArr then
						removeArr = {}
					end
					table.insert(removeArr, tf);
				end
			end

			if removeArr then
				for i,tf in ipairs(removeArr) do
					self._checkRenderDicOnShow[tf] = nil;
				end
				self._checkRenderLenOnShow = self._checkRenderLenOnShow - #removeArr;
			end
		end
	end
	self:checkStopTick()
end


textFieldMgr = TextFieldManager.new();