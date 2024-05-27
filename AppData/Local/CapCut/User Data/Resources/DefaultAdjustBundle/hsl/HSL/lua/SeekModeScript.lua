local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.hsl_param = {
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0),
        Amaz.Vector3f(0.0, 0.0, 0.0)
    }
    self.hsl_channels = {
        HSLRed=1,
        HSLOrange=2,
        HSLYellow=3,
        HSLGreen=4,
        HSLCyan=5,
        HSLBlue=6,
        HSLPurple=7,
        HSLMagenta=8
    }

    self.total_modes = 8
    self.slider_max_value = 100
    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:onUpdate(comp, detalTime)
    self:seekToTime(comp, detalTime)
end

function SeekModeScript:start(comp)
    self.material = comp.entity:getComponent("MeshRenderer").sharedMaterials:get(0)
end

function SeekModeScript:seekToTime(comp, time)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end
    for i = 1, self.total_modes do
        self.material:setVec3("hsl_param_" .. (i - 1), self.hsl_param[i])
    end
end

function SeekModeScript:onEvent(sys, event)
    local hslChannel = self.hsl_channels[event.args:get(0)]
    if hslChannel ~= nil then
        local hslValue = event.args:get(1)
        if (hslValue ~= nil and hslValue:size() >= 3) then
            local hue = hslValue:get(0)* 2.0 - 1.0
            local saturation = hslValue:get(1) * 2.0 - 1.0
            local lightness = hslValue:get(2) * 2.0 - 1.0
            -- Amaz.LOGE("AE_LUA_TAG", "[HSL] Setting "..tostring(event.args:get(0)).." to ["..tostring(hue)..", "..tostring(saturation)..", "..tostring(lightness).."]")
            self.hsl_param[hslChannel].x = hue * self.slider_max_value
            self.hsl_param[hslChannel].y = saturation * self.slider_max_value
            self.hsl_param[hslChannel].z = lightness * self.slider_max_value
        else
            Amaz.LOGE("AE_LUA_TAG", "[HSL] Setting "..tostring(hslChannel).." with invalid parameters!")
        end
    end
end

exports.SeekModeScript = SeekModeScript
return exports
