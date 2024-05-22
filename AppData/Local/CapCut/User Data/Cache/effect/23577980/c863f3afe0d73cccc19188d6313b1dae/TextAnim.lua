local exports = exports or {}
local TextAnim = TextAnim or {}
TextAnim.__index = TextAnim
function TextAnim.new(construct, ...)
	local self = setmetatable({}, TextAnim)
	self.text = nil
	self.duration = 1.0
	self.offset = 2 / 12
    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()

end

local function remap(smin, smax, dmin, dmax, value)
	return (value - smin) / (smax - smin) * (dmax - dmin) + dmin
end

local ae_attribute = {
	["ADBE_Scale_0_0"]={
		{{0.33333333,0.33333333,0.33333333, 0,0.33333333,0.33333333, 0.66666667,0.66666667,0.66666667, 1,0.66666667,0.66666667, }, {0, 4, }, {{0, 100, 100, }, {100, 100, 100, }, }, }, 
		{{0.33333333,0.33333333,0.33333333, 0,0.33333333,0.33333333, 0.66666667,0.66666667,0.66666667, 1,0.66666667,0.66666667, }, {4, 6, }, {{100, 100, 100, }, {90, 100, 100, }, }, }, 
		{{0.33333333,0.33333333,0.33333333, 0,0.33333333,0.33333333, 0.66666667,0.66666667,0.66666667, 1,0.66666667,0.66666667, }, {6, 8, }, {{90, 100, 100, }, {100, 100, 100, }, }, }, 
		{{0.33333333,0.33333333,0.33333333, 0,0.33333333,0.33333333, 0.66666667,0.66666667,0.66666667, 1,0.66666667,0.66666667, }, {8, 10, }, {{100, 100, 100, }, {95, 100, 100, }, }, }, 
		{{0.33333333,0.33333333,0.33333333, 0,0.33333333,0.33333333, 0.66666667,0.66666667,0.66666667, 1,0.66666667,0.66666667, }, {10, 12, }, {{95, 100, 100, }, {100, 100, 100, }, }, }, 
	}
}

function TextAnim:onStart(comp) 
	self.text = comp.entity:getComponent('SDFText')
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
	self.trans = comp.entity:getComponent("Transform")
    self.attrs = includeRelativePath("AETools"):new(ae_attribute)
	self:seek(0)
end

function TextAnim:onUpdate(comp, time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        self.curTime = self.curTime + time
		local t = self.curTime - math.floor(self.curTime / self.duration) * self.duration
        self:seek(t)
    end
end

function TextAnim:seek(time)
	local curTime = time / self.duration
	
	if self.text == nil then
		return 
	end

    local length = 1 + (self.text.chars:size() - 1) * self.offset
    local t = 1 / length

	for i = 1, self.text.chars:size() do
		local char = self.text.chars:get(i - 1)
            
		if char.rowth ~= -1 then
            local startT = (i-1) * self.offset * t
            local endT = startT + t

            local progress = 1
            if curTime < startT  then
                progress = 0
            elseif curTime > endT then
                progress = 1
            else
                progress = remap(startT, endT, 0, 1, curTime)
            end
            
            local scale = self.attrs:GetVal("ADBE_Scale_0_0",progress)[1] / 100
            char.scale = Amaz.Vector3f(scale,1,1)
		end

	end
    local chars = self.text.chars 
    self.text.chars= chars
end

function TextAnim:onEnter()
	self.first = true	
end

function TextAnim:resetData( ... )
	if self.text ~= nil then
    	local chars = self.text.chars 
		for i = 1, self.text.chars:size() do
			local char = chars:get(i - 1)
			if char.rowth ~= -1 then
				char.position = char.initialPosition
				char.rotate = Amaz.Vector3f(0, 0, 0)
				char.scale = Amaz.Vector3f(1, 1, 1)
				char.color = Amaz.Vector4f(1, 1, 1, 1)
			end
		end
		self.text.chars = chars
	end

	self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
	self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
	self.trans.localScale = Amaz.Vector3f(1, 1, 1)
end

function TextAnim:setDuration(duration)
   self.duration = duration
end
function TextAnim:onLeave()
	self:resetData()
end
function TextAnim:clear()
	self:resetData()
end

exports.TextAnim = TextAnim
return exports
