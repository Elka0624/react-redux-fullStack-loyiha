--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

 


function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    ---2787038086085111358-79500442448962578038740474249214672607
    --local props = comp.entity:getComponent("ScriptComponent").properties
    --if props:has("curTime") then
        --self:seekToTime(comp, props:get("curTime"))
    --end
    ---161275440519917640567922740006313600218740474249214672607
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    self.EASpeed = 1.0
    self.material = comp.entity:getComponent("MeshRenderer").material
end

function SeekModeScript:seekToTime(comp, time)

    self.material:setFloat("timer", time * self.EASpeed)
    
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.material:setInt("baseTexWidth", self.width)
        self.material:setInt("baseTexHeight", self.height)
    end
end




function SeekModeScript:onEvent(sys, event)
    --speed【0，0.5，1】【0.5，1，1.5】
    if "effects_adjust_speed" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.EASpeed = 1.5*intensity+0.5
    end
end


exports.SeekModeScript = SeekModeScript
return exports
