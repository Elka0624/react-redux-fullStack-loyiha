local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:onUpdate(comp, detalTime)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        self.buildScript = comp.entity.scene:findEntityBy("Camera_entity"):getComponent("ScriptComponent")
        local scriptObj = self:getLuaObj(self.buildScript)
        if scriptObj then
            self:seekToTime(comp, scriptObj.curTime - self.startTime)
        end
    else
        self:seekToTime(comp, self.curTime - self.startTime)
    end
end

function SeekModeScript:start(comp)
end

function SeekModeScript:onStart(comp)
    self.material = comp.entity.scene:findEntityBy("FliterEntity-2FFE6ABD"):getComponent("MeshRenderer").material
end

function SeekModeScript:getLuaObj(scriptComponent)
    if scriptComponent then
        local script = scriptComponent:getScript()
        if script then
            local luaObj = Amaz.ScriptUtils.getLuaObj(script)
            return luaObj
        end
    end
    return nil
end

function SeekModeScript:seekToTime(comp, time)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end

    local entities = comp.entity.scene.entities
    for i = 1, entities:size() do
        if entities:get(i - 1).name ~= "SeekModeScript" then
            local scriptComp = entities:get(i - 1):getComponent("ScriptComponent")
            if scriptComp then
                local scriptLuaObj = self:getLuaObj(scriptComp)
                if scriptLuaObj.seekToTime then
                    scriptLuaObj:seekToTime(scriptComp, time)
                end
            end
        end
    end
end

local function remap(dmin, dmax, value)
    return value * (dmax - dmin) + dmin
end

function SeekModeScript:onEvent(sys, event)
    -- if "effects_adjust_rotate" == event.args:get(0) then
    --     local intensity = event.args:get(1)
    --     self.material:setFloat("center", intensity + 0.001)
    -- end
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            local intensity = event.args:get(1) * 0.5 + 0.5
            if intensity >= 0.5 then
                self.material:setFloat("saturation", remap(1.0, 1.48, (intensity - 0.5) / 0.5))
                self.material:setFloat("center", 0.5 + 0.001)
                self.material:setFloat("sParamR", 0.24)
                self.material:setFloat("sParamG", 0.14)
                self.material:setFloat("sParamB", 0.17)
            else
                self.material:setFloat("saturation", remap(0.65, 1.0, intensity / 0.5))
                self.material:setFloat("center", 0.44 + 0.001)
                self.material:setFloat("sParamR", 0)
                self.material:setFloat("sParamG", 0)
                self.material:setFloat("sParamB", 0)
            end
        end
    end
    -- if "effects_adjust_speed" == event.args:get(0) then
    --     local intensity = event.args:get(1)
    --     self.material:setFloat("sParamR", intensity)
    -- end

    -- if "effects_adjust_filter" == event.args:get(0) then
    --     local intensity = event.args:get(1)
    --     self.material:setFloat("sParamG", intensity)
    -- end

    -- if "effects_adjust_texture" == event.args:get(0) then
    --     local intensity = event.args:get(1)
    --     self.material:setFloat("sParamB", intensity)
    -- end
end

exports.SeekModeScript = SeekModeScript
return exports
