local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
---@class SeekModeScript : ScriptComponent
---@field radius Vector2f
---@field bezier_tmp Vector4f
---@field huagan number [UI(Range={-1, 1}, Slider)]
---@field blendMode number [UI(Range={0, 26}, Slider, Drag=1)]
---@field alphaFactor number [UI(Range={0, 1}, Slider)]

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end

local function bezier(controls)
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(controls, t)
        local value =  getBezierValue(controls, tvalue)
        return b + c * value[2]
    end
end

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)

    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.radius = Amaz.Vector2f(0, 0)
    self.huagan = 0
    self.blendMode = 1
    self.alphaFactor = 1
    self.bezier_tmp = Amaz.Vector4f(0.2,0.45,0.63,0.81)
    return self
end

function SeekModeScript:constructor()
    self.name = "scriptComp"
end

function SeekModeScript:onStart(comp)
    self.daMat = comp.entity.scene:findEntityBy("dark_angle"):getComponent("MeshRenderer").material
end

function SeekModeScript:onUpdate(comp, deltaTime)
    self:seekToTime(comp, self.curTime)
end

function SeekModeScript:seekToTime(comp, deltaTime)
    self.daMat:setVec2("radius", self.radius)
    self.daMat:setFloat("huagan", self.huagan)
    self.daMat:setInt("blendMode", self.blendMode)
    self.daMat:setFloat("alphaFactor", self.alphaFactor)

    if self.huagan > 0 then
        self.daMat:setFloat("out_huagan", bezier(changeVec4ToTable(self.bezier_tmp))(self.huagan * 0.5 + 0.5, 0, 1, 1) * 2 - 1)
    else
        self.daMat:setFloat("out_huagan", bezier({.65,.2,.81,.63})(self.huagan * 0.5 + 0.5, 0, 1, 1) * 2 - 1)
    end
end

function SeekModeScript:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            local intensity = event.args:get(1)
            self.huagan = intensity
        end
    end
end

exports.SeekModeScript = SeekModeScript
return exports
