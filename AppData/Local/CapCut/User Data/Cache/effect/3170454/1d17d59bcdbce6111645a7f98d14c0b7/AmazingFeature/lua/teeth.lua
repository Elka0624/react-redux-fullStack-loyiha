local exports = exports or {}
local teeth = teeth or {}
teeth.__index = teeth

-- output
local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local FACE_ADJUST_INTENSITY = "intensity"

-- runtime
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG teeth.lua"

function teeth.new(construct, ...)
    local self = setmetatable({}, teeth)

    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.faceAdjustMaps = {}

    -- init
    local defaultMap = Amaz.Map()
    defaultMap:set(FACE_ID, -1)
    defaultMap:set(FACE_ADJUST_INTENSITY, 0)
    self.faceAdjustMaps[-1] = defaultMap

    return self
end

function teeth:onStart(comp, script)
    local scene = comp.entity.scene
    self.scriptProps = comp.properties
    self.makeupEntity = scene:findEntityBy("teeth")
    self.makeupComp = self.makeupEntity:getComponent("EffectFaceMakeupFaceULipKeypoint")
end

function teeth:onUpdate(comp, deltaTime)
    -- get face info by size order
    self:updateFaceInfoBySize()

    -- update face with valid track id
    local isVisible = false
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local intensity = 0
        if id ~= -1 and i <= self.maxDisplayNum then
            local adjustMap = self.faceAdjustMaps[id]
            if adjustMap == nil then
                adjustMap = self.faceAdjustMaps[-1]
                Amaz.LOGI("lydebug baiya use default id:", id)
            end
            intensity = adjustMap:get(FACE_ADJUST_INTENSITY)
        end
        if intensity > EPSC then
            isVisible = true
        end
        Amaz.LOGI("lydebug baiya onUpdate id:", id)
        Amaz.LOGI("lydebug baiya onUpdate intensity:", intensity)
        self.makeupComp:setFaceUniform("opacity", faceInfo.index, intensity)
    end
    self.makeupEntity.visible = isVisible

    Amaz.LOGI("lydebug baiya onupdate self address", tostring(self.faceAdjustMaps))
end

function teeth:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function teeth:handleIntensityEvent(comp, event)
    if event.args:get(0) == FACE_ADJUST then
        Amaz.LOGI("lydebug baiya event enter", "!!!")
        self.faceAdjustMaps = {}
        local inputVector = event.args:get(1)
        local inputSize = inputVector:size()
        for i = 0, inputSize - 1 do
            local inputMap = inputVector:get(i)
            local inputId = inputMap:get(FACE_ID)
            local inputIntensity = inputMap:get(FACE_ADJUST_INTENSITY)
            Amaz.LOGI("lydebug baiya event id:", inputId)
            Amaz.LOGI("lydebug baiya event intensity:", inputIntensity)

            local tmpMap = Amaz.Map()
            tmpMap:set(FACE_ID, inputId)
            tmpMap:set(FACE_ADJUST_INTENSITY, inputIntensity)
            self.faceAdjustMaps[inputId] = tmpMap

            local ttmpMap = self.faceAdjustMaps[inputId]
            if ttmpMap == nil then
                Amaz.LOGI("lydebug baiya event so weid", "###")
            end
            Amaz.LOGI("lydebug baiya event self address", tostring(self.faceAdjustMaps))
        end
    end
end

function teeth:updateFaceInfoBySize()
    self.faceInfoBySize = {}

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()

    -- Amaz.LOGI("lydebug baiya updateFaceInfoBySize faceCount:", faceCount)
    Amaz.LOGI("lydebug baiya updateFaceInfoBySize freidCount:", freidCount)

    for i = 0, self.maxFaceNum - 1 do
        local trackId = -1
        local faceSize = 0
        if i < faceCount then
            local baseInfo = result:getFaceBaseInfo(i)
            local faceId = baseInfo.ID
            local faceRect = baseInfo.rect
            for j = 0, freidCount - 1 do
                local freidInfo = result:getFreidInfo(j)
                if faceId == freidInfo.faceid then
                    trackId = freidInfo.trackid
                end
            end
            Amaz.LOGI("lydebug baiya updateFaceInfoBySize faceId:", faceId)
            Amaz.LOGI("lydebug baiya updateFaceInfoBySize trackId:", trackId)
            faceSize = faceRect.width * faceRect.height
            Amaz.LOGI("lydebug baiya updateFaceInfoBySize faceSize:", faceSize)
        end
        table.insert(self.faceInfoBySize, {
            index = i,
            id = trackId,
            size = faceSize
        })
    end
    table.sort(self.faceInfoBySize, function(a, b)
        return a.size > b.size
    end)
end

exports.teeth = teeth
return exports