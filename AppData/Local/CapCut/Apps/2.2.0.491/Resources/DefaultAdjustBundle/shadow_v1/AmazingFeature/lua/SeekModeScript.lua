--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

---@class SeekModeScript: ScriptComponent
----@field ratio number
----@field windowSize int
----@field blurSize number
----@field renderTextureNum int
----@field autoPlay boolean
----@field playTime number

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    return self
end

function SeekModeScript:onUpdate(comp, detalTime)
    -- if Amaz.Macros and Amaz.Macros.EditorSDK then
    --     self:initData()
    -- -- self:start()
    -- else
    -- self.duration = self.endTime - self.startTime
    -- end
    if self.autoPlay or (not (Amaz.Macros and Amaz.Macros.EditorSDK)) then
        self.curTime = self.curTime + detalTime
        self:seekToTime(comp, self.curTime - self.startTime)
    else
        self:seekToTime(comp, self.playTime)
    end
end

---@param comp ScriptComponent
function SeekModeScript:onStart(comp)
    -- self.material = comp.entity:getComponent("MeshRenderer").material
    self.tableComponent = comp.entity:getComponent("TableComponent").table
    self.width = 0
    self.height = 0
    self.isFirst = true
    self.isSecond = false
    self.isDefaultPos = false
    self.renderTexture = {}
    self.material = {}
    for i = 1, self.renderTextureNum do
        self.renderTexture[i] = self.tableComponent:get("midTex" .. i)
    end
    for i = 2, 7 do
        self.material[i] = comp.entity.scene:findEntityBy("boxFilter_"..i):getComponent("MeshRenderer").material
    end
end

-- function SeekModeScript:beforeEditorSave()
--     Amaz.Algorithm.setAlgorithmEnable("", "face_0", false)
--     Amaz.Algorithm.setAlgorithmEnable("", "skeleton_0", true)
--     self.entityLuas["face"].entity.visible = true
-- end

function SeekModeScript:seekToTime(comp, time)
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if self.width ~= w or self.height ~= h or (Amaz.Macros and Amaz.Macros.EditorSDK) then
        self.width = w
        self.height = h
        for i = 1, self.renderTextureNum do
            self.renderTexture[i].height = self.height * self.ratio
            self.renderTexture[i].width = self.width * self.ratio
        end
        for i = 2, 7 do
            self.material[i]:enableMacro("blur_Num",self.windowSize)
            self.material[i]["u_blurSize"] = self.blurSize
        end
    end

    
end

function SeekModeScript:onEvent(sys, event)

end

exports.SeekModeScript = SeekModeScript
return exports
