local exports = exports or {}
local Transform = Transform or {}
Transform.__index = Transform
function Transform.new(construct, ...)
    local self = setmetatable({}, Transform)
    if construct and Transform.constructor then Transform.constructor(self, ...) end
    return self
end

function Transform:constructor()

end

local grain_max_width = 1200
local grain_max_height = 1200
local grain_max_width_inv = 0.00195312 -- 1. / 512
local grain_max_height_inv = 0.00195312

local height = 0.
local width = 0.
-- local count = 0
-- local max_count = 0
local random_x1 = 0.
local random_y1 = 0.

function Transform:onStart(comp)
    self.renderer = comp.entity:getComponent("Sprite2DRenderer")


    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    width = w
    height = h
    -- self.renderer.material:setFloat("ratio", 1.0)
    local height_inv = 0
    local width_inv = 0
    if height ~= 0 then
        height_inv = 1. / height
    end
    if width ~= 0 then
        width_inv = 1. / width
    end

    local grain_width
    local grain_height
    local u_max
    local v_max
    if height >= width then
        grain_width = grain_max_width
        grain_height = grain_max_width * width_inv * height
    else
        grain_width = grain_max_height * height_inv * width
        grain_height = grain_max_height
    end

    u_max = grain_width * grain_max_width_inv
    v_max = grain_height * grain_max_height_inv
    self.renderer.material:setFloat( "u_max", u_max)
    self.renderer.material:setFloat( "v_max", v_max)

    random_x1 = math.random()
    random_y1 = math.random()

    self.renderer.material:setFloat( "random_x1", random_x1)
    self.renderer.material:setFloat( "random_y1", random_y1)
end

function Transform:onEvent(comp, event)

    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            self.renderer.material["ratio"] = event.args:get(1)
        end
    end
end

exports.Transform = Transform
return exports
