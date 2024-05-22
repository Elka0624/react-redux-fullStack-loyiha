
local exports = exports or {}
local TextScript = TextScript or {}

---@class TextScript : ScriptComponent
---@field glow_intensity number
---@field radius number
TextScript.__index = TextScript

function TextScript.new()
    local self = {}
    setmetatable(self, TextScript)
    self.transform = {}
    self.glow_intensity = 0
    self.radius = 256
    self.first = true
    return self
end

---@param comp Component
function TextScript:onStart(comp)
    self.blendMat = comp.entity:searchEntity("Blend"):getComponent("MeshRenderer").material
    self.text = comp.entity:searchEntity("TestText"):getComponent("SDFText")
    self.first = true
end

---@param comp Component
---@param deltaTime number
function TextScript:onUpdate(comp, deltaTime)
    if self.first == true then
        local GlowBlurRoot1Lua = self.text.entity.scene:findEntityBy("GlowBlur_1"):getComponent("ScriptComponent")
        self.LuaObj1 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot1Lua:getScript())
        local GlowBlurRoot2Lua = self.text.entity.scene:findEntityBy("GlowBlur_2"):getComponent("ScriptComponent")
        self.LuaObj2 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot2Lua:getScript())
        local GlowBlurRoot3Lua = self.text.entity.scene:findEntityBy("GlowBlur_3"):getComponent("ScriptComponent")
        self.LuaObj3 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot3Lua:getScript())
        self.first = false
    end
    self.blendMat:setVec4("u_TextColor", Amaz.Vector4f(self.text.textColor.x, self.text.textColor.y, self.text.textColor.z, 1.0))
    self.blendMat:setFloat("u_GlowIntensity", self.glow_intensity)
    self.LuaObj1.Intensity = self.radius / 16
    self.LuaObj2.Intensity = self.radius
    self.LuaObj3.Intensity = self.radius
end

---@param comp Component
---@param event Event
function TextScript:onEvent(comp, event)
end

exports.TextScript = TextScript
return exports
