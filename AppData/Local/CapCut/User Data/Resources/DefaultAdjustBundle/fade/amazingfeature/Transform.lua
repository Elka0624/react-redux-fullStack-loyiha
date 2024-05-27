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

function Transform:onStart(comp)
    self.renderer = comp.entity:getComponent("Sprite2DRenderer")
end

function Transform:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            self.renderer.material["intensity"] = event.args:get(1)
        end
    end
end

exports.Transform = Transform
return exports
