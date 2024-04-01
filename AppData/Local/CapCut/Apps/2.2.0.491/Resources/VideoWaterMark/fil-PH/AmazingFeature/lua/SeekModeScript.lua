--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0

    self.inputWidth = -1
    self.inputHeight = -1
    self.waterMarkWidth = -1
    self.waterMarkHeight = -1

    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    --
    -- local props = comp.entity:getComponent("ScriptComponent").properties
    -- if props:has("curTime") then
    --     self:seekToTime(comp, props:get("curTime") - self.startTime)
    -- end
    --
    -- self.curTime = self.curTime + detalTime
    -- self:seekToTime(comp, self.curTime - self.startTime)
end


function SeekModeScript:getWaterMark(comp)
    self.waterMarkMeterial = comp.entity.scene:findEntityBy("water_mark"):getComponent("MeshRenderer").material

    local texture = self.waterMarkMeterial:getTex("waterMarkTexture")
    if texture == nil then
        Amaz.LOGE("waterMark", "water mark is nil, skip update")
        return
    end

    self.waterMarkWidth = texture.width
    self.waterMarkHeight  = texture.height

end


function SeekModeScript:onStart(comp)
    self:getWaterMark(comp)
    self:viewSizeEvent()
    
end

function SeekModeScript:viewSizeEvent()
    
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w > h then
        local ratioY = 1.0
        local ratioX = 1.0 * w / h
        self.waterMarkMeterial:setFloat("ratioX", ratioX)
        self.waterMarkMeterial:setFloat("ratioY", ratioY)
    else
        local ratioX = 1.0
        local ratioY = 1.0 * h / w
        self.waterMarkMeterial:setFloat("ratioX", ratioX)
        self.waterMarkMeterial:setFloat("ratioY", ratioY)
    end
 
end

function SeekModeScript:onEvent(sys, event)
    if event.type == 2 then
        self:viewSizeEvent()
    end
end
exports.SeekModeScript = SeekModeScript
return exports
