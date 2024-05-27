--write by editor  EffectSDK:10.1.0 EngineVersion:10.62.0 EditorBuildTime:Oct_14_2021_20_28_37
--sliderVersion: 20210901  Lua generation date: Fri Feb 11 14:40:14 2022

local exports = exports or {}
local ImageBusinessSlider = ImageBusinessSlider or {}
ImageBusinessSlider.__index = ImageBusinessSlider

function ImageBusinessSlider.new(construct, ...)
    local self = setmetatable({}, ImageBusinessSlider)
    if construct and ImageBusinessSlider.constructor then
        ImageBusinessSlider.constructor(self, ...)
    end
    self.shadow = 0
    return self
end

local function remap(x, a, b)
    return x * (b - a) + a
end

function ImageBusinessSlider:onStart(sys)
    self.cameraAdjustMaterial0 = sys.scene:findEntityBy("cameraAdjust"):getComponent("Renderer").material
end
function ImageBusinessSlider:onUpdate(sys, detalTime)
    local x = self.shadow * 0.01
    x = math.pow(math.abs(x), 8.0)
    local lf = 0.28 * x
    local sf1 = 0.0 * x
    local sf2 = -0.12 * x
    if self.shadow < 0 then
        lf = 0.2 * x
        sf2 = 0.08 * x
    end
    self.cameraAdjustMaterial0["lf"] = lf
    self.cameraAdjustMaterial0["sf1"] = sf1
    self.cameraAdjustMaterial0["sf2"] = sf2
end

function ImageBusinessSlider:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            local intensity = event.args:get(1)
            self.shadow = intensity * 100
            self.cameraAdjustMaterial0["shadow"] = self.shadow
        end
    end
end

exports.ImageBusinessSlider = ImageBusinessSlider
return exports
