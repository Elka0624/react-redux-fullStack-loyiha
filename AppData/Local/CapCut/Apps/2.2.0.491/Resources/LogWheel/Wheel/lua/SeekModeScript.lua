local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end

    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:onUpdate(comp, detalTime)
    self:seekToTime(comp, detalTime)
end

function SeekModeScript:start(comp)
    self.material = comp.entity:getComponent("MeshRenderer").sharedMaterials:get(0)

    self.material:setFloat("Intensity", 0.);
    self.material:setFloat("ShadowR", 0.);
    self.material:setFloat("ShadowG", 0.);
    self.material:setFloat("ShadowB", 0.);
    self.material:setFloat("ShadowS", 0.);
    self.material:setFloat("MidtoneR", 0.);
    self.material:setFloat("MidtoneG", 0.);
    self.material:setFloat("MidtoneB", 0.);
    self.material:setFloat("MidtoneS", 0.);
    self.material:setFloat("HightlightsR", 0.);
    self.material:setFloat("HightlightsG", 0.);
    self.material:setFloat("HightlightsB", 0.);
    self.material:setFloat("HightlightsS", 0.);
    self.material:setFloat("OffsetR", 0.);
    self.material:setFloat("OffsetG", 0.);
    self.material:setFloat("OffsetB", 0.);
    self.material:setFloat("OffsetS", 0.);
    self.material:setFloat("RugDown", 0.333);
    self.material:setFloat("RugUP", 0.555);
end

function SeekModeScript:seekToTime(comp, time)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end
end

local function clamp(val, min, max)
    return math.max(math.min(val, max), min)
end

local function adjustShadow(shadow)
    local res = shadow
    if shadow < 0. then
        res = -8.0 * shadow * shadow
    end
    return res
end

local function adjustHightlights(hightlights)
    local res = hightlights
    if hightlights > 0. then
        res = 8.0 * hightlights * hightlights
    end
    return res
end

function SeekModeScript:onEvent(sys, event)
    if self.first == nil then
        self.first = true
        self:start(sys)
    end
    if self.material == nil then 
        return
    end
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        local intensity = clamp(event.args:get(1), -1, 1)
        if ("Intensity" == event.args:get(0)) then
            self.material:setFloat("Intensity", intensity);
        elseif ("ShadowR" == event.args:get(0)) then
            self.material:setFloat("ShadowR", adjustShadow(intensity));
        elseif ("ShadowG" == event.args:get(0)) then
            self.material:setFloat("ShadowG", adjustShadow(intensity));
        elseif ("ShadowB" == event.args:get(0)) then
            self.material:setFloat("ShadowB", adjustShadow(intensity));
        elseif ("ShadowS" == event.args:get(0)) then
            self.material:setFloat("ShadowS", adjustShadow(intensity*0.5));
        elseif ("MidtoneR" == event.args:get(0)) then
            self.material:setFloat("MidtoneR", intensity);
        elseif ("MidtoneG" == event.args:get(0)) then
            self.material:setFloat("MidtoneG", intensity);
        elseif ("MidtoneB" == event.args:get(0)) then
            self.material:setFloat("MidtoneB", intensity);
        elseif ("MidtoneS" == event.args:get(0)) then
            self.material:setFloat("MidtoneS", intensity*0.5);
        elseif ("HightlightsR" == event.args:get(0)) then
            self.material:setFloat("HightlightsR", adjustHightlights(intensity));
        elseif ("HightlightsG" == event.args:get(0)) then
            self.material:setFloat("HightlightsG", adjustHightlights(intensity));
        elseif ("HightlightsB" == event.args:get(0)) then
            self.material:setFloat("HightlightsB", adjustHightlights(intensity));
        elseif ("HightlightsS" == event.args:get(0)) then
            self.material:setFloat("HightlightsS", adjustHightlights(intensity*0.5));
        elseif ("OffsetR" == event.args:get(0)) then
            self.material:setFloat("OffsetR", intensity);
        elseif ("OffsetG" == event.args:get(0)) then
            self.material:setFloat("OffsetG", intensity);
        elseif ("OffsetB" == event.args:get(0)) then
            self.material:setFloat("OffsetB", intensity);
        elseif ("OffsetS" == event.args:get(0)) then
            self.material:setFloat("OffsetS", intensity);
        elseif ("RugDown" == event.args:get(0)) then
            self.material:setFloat("RugDown", intensity);
        elseif ("RugUP" == event.args:get(0)) then
            self.material:setFloat("RugUP", intensity);
        end
    end
end

exports.SeekModeScript = SeekModeScript
return exports
