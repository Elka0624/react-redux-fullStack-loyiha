--@input float curTime = 0.0{"widget":"slider","min":0,"max":10}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 10.0  
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    self.speed = 1.0
    return self
end

function SeekModeScript:onStart(comp)

end

function SeekModeScript:onUpdate(comp, detalTime)
end

function SeekModeScript:seekToTime(comp, time)
end


exports.SeekModeScript = SeekModeScript
return exports






