--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0

    self.direction = {{-1,-1},{-1,1},{1,1},{1,-1},{0,0}}
    self.intensity = 0.02     -- 907729113921900055121671907409362110908216102072969055023-7803383449676293555
    self.fps = 15  -- 90772911392190005512167190740936211090-7618641142768116163493407193133078681

    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    ---2787038086085111358-79500442448962578038740474249214672607
    --local props = comp.entity:getComponent("ScriptComponent").properties
    --if props:has("curTime") then
        --self:seekToTime(comp, props:get("curTime"))
    --end
    ---161275440519917640567922740006313600218740474249214672607
    --self.curTime =self.curTime + detalTime
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    self.EASpeed = 1.0
    self.material = comp.entity:getComponent("MeshRenderer").material
end

function SeekModeScript:seekToTime(comp, time)

    local id = math.floor(time*self.fps)    
    id = math.mod(id,10)+1
    if id>5 then 
        id = 10-id
        if id == 0 then
            id = 5
        end
    end
    self.material:setVec2("direction", Amaz.Vector2f(self.direction[id][1]*self.intensity, self.direction[id][2]*self.intensity))
    
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.material:setInt("baseTexWidth", self.width)
        self.material:setInt("baseTexHeight", self.height)
    end
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_speed" == event.args:get(0) then
        local its = event.args:get(1)
        self.fps = 15*its+15
    end
    if "effects_adjust_intensity" == event.args:get(0) then
        local its = event.args:get(1)
        self.intensity = 0.04*its
    end
end


exports.SeekModeScript = SeekModeScript
return exports
