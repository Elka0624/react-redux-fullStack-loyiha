local exports = exports or {}
local GlowBlurLayerScript = GlowBlurLayerScript or {}

---@class GlowBlurLayerScript : ScriptComponent
---@field Intensity number
---@field Blurred_Direction string[UI(Option={"Horizontal and Vertical", "Horizontal", "Vertical"})]
GlowBlurLayerScript.__index = GlowBlurLayerScript

function GlowBlurLayerScript.new()
    local self = {}
    setmetatable(self, GlowBlurLayerScript)
    self.Intensity = 0.0
    self.Blurred_Direction = "Horizontal and Vertical"
    self.transform = {}
    return self
end

---@param comp Component
function GlowBlurLayerScript:onStart(comp)
    self.HorizontalBlurMat = comp.entity:searchEntity("GlowBlurH"):getComponent("MeshRenderer").material
    self.VerticalBlurMat = comp.entity:searchEntity("GlowBlurV"):getComponent("MeshRenderer").material
    self.entity = comp.entity
end

---@param comp Component
---@param deltaTime number
function GlowBlurLayerScript:onUpdate(comp, deltaTime)

    local intensity = math.max(self.Intensity, 0.0)
    self.HorizontalBlurMat:enableMacro("GLOWSAMPLE", math.floor(intensity))
    self.VerticalBlurMat:enableMacro("GLOWSAMPLE", math.floor(intensity))
    if self.Blurred_Direction == "Horizontal" then
        self.VerticalBlurMat:enableMacro("GLOWSAMPLE", 0)
    end
    if self.Blurred_Direction == "Vertical" then
        self.HorizontalBlurMat:enableMacro("GLOWSAMPLE", 0)
    end
end

---@param comp Component
---@param event Event
function GlowBlurLayerScript:onEvent(comp, event)
end

exports.GlowBlurLayerScript = GlowBlurLayerScript
return exports
