--write by editor  EffectSDK:10.5.0 EngineVersion:10.66.0 EditorBuildTime:Dec__7_2021_12_06_29
--sliderVersion: 20210901  Lua generation date: Fri Feb 11 11:39:23 2022


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
    self.Pass1Material0 = sys.scene:findEntityBy("Pass1"):getComponent("Renderer").material
end


function ImageBusinessSlider:onEvent(sys,event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            local intensity = event.args:get(1)*0.5+0.5
            if intensity >0.5 then
                if intensity<0.85 then
                    intensity = intensity*0.3+0.35
                else
                    intensity = intensity*0.6333+0.0667
                end
            end
            self.Pass1Material0["light"] = remap(intensity,-1,1)
        end
    end
end


exports.ImageBusinessSlider = ImageBusinessSlider
return exports