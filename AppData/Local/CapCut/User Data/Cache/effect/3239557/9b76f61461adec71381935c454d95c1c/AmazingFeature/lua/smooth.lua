local exports = exports or {}
local smooth = smooth or {}
smooth.__index = smooth

-- runtime
local MIN = math.min
local MAX = math.max
local MOD = math.modf
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG smooth.lua"

function smooth.new(construct, ...)
    local self = setmetatable({}, smooth)

    self.intensity = 1
    self.hasFaceFlag = 1

    return self
end

function smooth:onStart(comp, script)
    local scene = comp.entity.scene
    self.scriptProps = comp.properties
    local segmentId = self.scriptProps:get(SEGMENT_ID)
    if segmentId ~= nil then
        self.logTag = string.format('%s %s', LOG_TAG, segmentId)
    else
        self.logTag = LOG_TAG
    end

    self.showSmooth = scene:findEntityBy("Group2")
    self.hsvMaterial = scene:findEntityBy("hsv"):getComponent("MeshRenderer").material
    self.blur1Material = scene:findEntityBy("blur1"):getComponent("MeshRenderer").material
    self.blur2Material = scene:findEntityBy("blur2"):getComponent("MeshRenderer").material
    self.blur3Material = scene:findEntityBy("blur3"):getComponent("MeshRenderer").material
    self.blur4Material = scene:findEntityBy("blur4"):getComponent("MeshRenderer").material
    self.blend2Material = scene:findEntityBy("blend2"):getComponent("MeshRenderer").material

end

function smooth:onUpdate(comp, deltaTime)
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    if faceCount > 0 then
        self.blend2Material:setFloat("smoothIntensity", self.intensity)
    else
        self.hsvMaterial:setFloat("hasFaceFlag", self.hasFaceFlag)
        self.blend2Material:setFloat("smoothIntensity", self.intensity)
    end

    -- update render state
    self.inputWidth = Amaz.BuiltinObject:getInputTextureWidth()
    self.inputHeight = Amaz.BuiltinObject:getInputTextureHeight()
    self.widthOffset = 1 / MOD(self.inputWidth * 0.45)
    self.heightOffset = 1 / MOD(self.inputHeight * 0.45)
    self.blur1Material:setFloat("texBlurWidthOffset", self.widthOffset)
    self.blur2Material:setFloat("texBlurHeightOffset", self.heightOffset)
    self.blur3Material:setFloat("widthOffset", self.widthOffset)
    self.blur3Material:setFloat("heightOffset", self.heightOffset)
    self.blur4Material:setFloat("widthOffset", self.widthOffset)
    self.blur4Material:setFloat("heightOffset", self.heightOffset)

end

function smooth:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            self.intensity = event.args:get(1)
        end
    end

end

exports.smooth = smooth
return exports