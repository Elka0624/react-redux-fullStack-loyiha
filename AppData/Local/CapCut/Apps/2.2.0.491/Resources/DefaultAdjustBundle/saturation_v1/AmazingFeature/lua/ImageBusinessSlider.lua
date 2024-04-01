--write by editor  EffectSDK:10.9.0 EngineVersion:10.68.0 EditorBuildTime:Jan_21_2022_06_47_17
--sliderVersion: 20210901  Lua generation date: Fri Feb 11 10:57:42 2022

local exports = exports or {}
local ImageBusinessSlider = ImageBusinessSlider or {}
ImageBusinessSlider.__index = ImageBusinessSlider

function ImageBusinessSlider.new(construct, ...)
    local self = setmetatable({}, ImageBusinessSlider)
    if construct and ImageBusinessSlider.constructor then
        ImageBusinessSlider.constructor(self, ...)
    end
    return self
end

local function remap(x, a, b)
    return x * (b - a) + a
end

function ImageBusinessSlider:onStart(sys)
    self.SatMaterial0 = sys.scene:findEntityBy("Sat"):getComponent("Renderer").material
end

function ImageBusinessSlider:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            -- self.SatMaterial0["sat"] = event.args:get(1)
            local intensity = (event.args:get(1) * 0.5 + 0.5) * 100
            self.SatMaterial0["sat"] = intensity
        end
    end

    -- if event.args:get(0) == "effects_adjust_intensity" then
    --     local intensity = event.args:get(1)
    --     self.SatMaterial0["sat"] = remap(intensity,0,100)
    -- end
end

exports.ImageBusinessSlider = ImageBusinessSlider
return exports
