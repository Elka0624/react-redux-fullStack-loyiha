local exports = exports or {}
local reshape = reshape or {}
reshape.__index = reshape

-- output
local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local FACE_ADJUST_INTENSITY = "intensity"

-- runtime
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "FACE_BEAUTY_TAG reshape.lua"

local RESET_PARAMS = "reset_params"

function reshape.new(construct, ...)
    local self = setmetatable({}, reshape)

    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.organParams = {
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        2,
        0,
        0,
    }
    self.faceAdjustMaps = {}

    -- init
    local defaultMap = Amaz.Map()
    defaultMap:set(FACE_ID, -1)
    defaultMap:set(FACE_ADJUST_INTENSITY, 0)
    self.faceAdjustMaps[-1] = defaultMap

    return self
end

function reshape:onStart(comp, script)
    local scene = comp.entity.scene
    self.scriptProps = comp.properties
    self.reshapeEntities = {}
    self.reshapeComps = {}

    local scriptScene = script.scene
    local scriptSystem = scriptScene:getSystem("ScriptSystem")
    scriptSystem:clearAllEventType()
    scriptSystem:addEventType(Amaz.AppEventType.SetEffectIntensity)

    for i = 0, self.maxFaceNum - 1 do
        self.reshapeEntities[i] = scene:findEntityBy("reshape_" .. i + 1)
        self.reshapeComps[i] = self.reshapeEntities[i]:getComponent("FaceReshape")
    end

    self.path = scene.assetMgr.rootDir
    self.materialSingle = scene.assetMgr:SyncLoad(self.path .. "material/FaceDistortionV5Material1.material")
    self.materialMultiy = scene.assetMgr:SyncLoad(self.path .. "material/FaceDistortionV5Material0.material")

    self.singlePer = false
    self.multiPer = false
    local algRes = Amaz.Algorithm.getAEAlgorithmResult()
    self.person_count = algRes:getFaceCount()
    if self.person_count > 1 then
        self.multiPer = true
        for i = 0, self.maxFaceNum - 1, 1 do
            self.reshapeComps[i].entity:getComponent("MeshRenderer").material = self.materialMultiy
        end
    elseif self.person_count <= 1 then
        self.singlePer = true;
    end
    Amaz.LOGI(LOG_TAG, "onStart finished.")
end

function reshape:onUpdate(comp, deltaTime)
    -- select material by person count
    local algRes = Amaz.Algorithm.getAEAlgorithmResult()
    self.person_count = algRes:getFaceCount()
    if self.person_count > 1 and self.singlePer == true then
        for i = 0, self.maxFaceNum - 1, 1 do
            self.reshapeComps[i].entity:getComponent("MeshRenderer").sharedMaterial = self.materialMultiy
        end
        self.singlePer = false
        self.multiPer = true
    elseif self.person_count <= 1 and self.multiPer == true then
        for i = 0, self.maxFaceNum - 1, 1 do
            self.reshapeComps[i].entity:getComponent("MeshRenderer").sharedMaterial = self.materialSingle
        end
        self.singlePer = true
        self.multiPer = false
    end

    -- get face info by size order
    self:updateFaceInfoBySize()

    -- update face with valid track id
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index
        local intensity = 0
        if id ~= -1 and i <= self.maxDisplayNum then
            local adjustMap = self.faceAdjustMaps[id]
            if adjustMap == nil then
                adjustMap = self.faceAdjustMaps[-1]
            end
            intensity = adjustMap:get(FACE_ADJUST_INTENSITY)
        end
        if intensity > EPSC then
            self.reshapeEntities[index].visible = true
            local degrees = self.reshapeComps[index].params.degrees
            degrees:set(1, self.organParams[2] + 0.14 * intensity)
        else
            self.reshapeEntities[index].visible = false
        end
    end
end

function reshape:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function reshape:handleIntensityEvent(comp, event)
    if event.args:get(0) == RESET_PARAMS then
        self.faceAdjustMaps = {}
        Amaz.LOGI(LOG_TAG, "onEvent reset params")
    elseif event.args:get(0) == FACE_ADJUST then
        self.faceAdjustMaps = {}
        local inputVector = event.args:get(1)
        local inputSize = inputVector:size()
        for i = 0, inputSize - 1 do
            local inputMap = inputVector:get(i)
            local inputId = inputMap:get(FACE_ID)
            self.faceAdjustMaps[inputId] = inputMap
        end
    end
end

function reshape:updateFaceInfoBySize()
    self.faceInfoBySize = {}

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()
    for i = 0, self.maxFaceNum - 1 do
        local trackId = -1
        local faceSize = 0
        local faceYaw = 0.0
        if i < faceCount then
            local baseInfo = result:getFaceBaseInfo(i)
            local faceId = baseInfo.ID
            local faceRect = baseInfo.rect
            for j = 0, freidCount - 1 do
                local freidInfo = result:getFreidInfo(j)
                if faceId == freidInfo.faceid then
                    trackId = freidInfo.trackid
                    faceYaw = baseInfo.yaw
                end
            end
            faceSize = faceRect.width * faceRect.height
        end
        table.insert(self.faceInfoBySize, {
            index = i,
            id = trackId,
            size = faceSize,
            yaw = faceYaw
        })
    end
    table.sort(self.faceInfoBySize, function(a, b)
        if (math.abs(a.size - b.size) > 0.000001) then 
            return a.size > b.size
        else
            return math.abs(a.yaw) < math.abs(b.yaw)
        end 
    end)
end

exports.reshape = reshape
return exports