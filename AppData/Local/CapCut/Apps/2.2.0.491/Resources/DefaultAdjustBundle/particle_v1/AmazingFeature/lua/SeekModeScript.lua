
local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    self.lightNoise = 22.0
    self.darkNoise = 50.0

    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:onUpdate(comp, detalTime)

    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)

    self.noiseMaterial = comp.entity.scene:findEntityBy("noise"):getComponent("MeshRenderer").material


    self.firstWidth = Amaz.BuiltinObject:getInputTextureWidth()
    self.firstHeight = Amaz.BuiltinObject:getInputTextureHeight()


    self.zoom = 1
end

function SeekModeScript:seekToTime(comp, time)
    -- if self.first == nil then
    --     self.first = true
    --     self:start(comp)
    -- end

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        local zoom_factor = 1
        local mW = self.width * zoom_factor
        local mH = self.height * zoom_factor
        self.noiseMaterial:setInt("imageWidth", mW)
        self.noiseMaterial:setInt("imageHeight", mH)

    end
    local intensity = 0.5
    self.noiseMaterial:setFloat("grayIns", intensity)
    local props = comp.entity:getComponent("ScriptComponent").properties
end

function SeekModeScript:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            local intensity = event.args:get(1)
            self.noiseMaterial:setInt("lightNoise", math.floor(1 + intensity * self.lightNoise))
            self.noiseMaterial:setInt("darkNoise", math.floor(1 + intensity * self.darkNoise))
        end
    end
    
end

exports.SeekModeScript = SeekModeScript
return exports
