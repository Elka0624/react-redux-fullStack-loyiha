local exports = exports or {}
local reshape = reshape or {}
reshape.__index = reshape

-- output
local FACE_ID = "id"
local INTENSITY_TAG = "intensity"

local Item_TotalFace = "face_adjust_TotalFace"
local Item_EyeSpacing = "face_adjust_EyeSpacing"
local Item_EnlargeEye = "face_adjust_EnlargeEye"
local Item_MoveEye = "face_adjust_MoveEye"
local Item_Nose = "face_adjust_Nose"
local Item_MoveNose = "face_adjust_MoveNose"
local Item_MoveMouth = "face_adjust_MoveMouth"
local Item_ZoomMouth = "face_adjust_ZoomMouth"
local Item_Chin = "face_adjust_Chin"
local Item_Forehead = "face_adjust_Forehead"
local Item_CutFace = "face_adjust_CutFace"
local Item_SmallFace = "face_adjust_SmallFace"
local Item_ZoomJawbone = "face_adjust_ZoomJawbone"
local Item_ZoomCheekbone = "face_adjust_ZoomCheekbone"
local Item_MouthCorner = "face_adjust_MouthCorner"
local Item_CornerEye = "face_adjust_CornerEye"
local Item_ChinSharp = "face_adjust_ChinSharp"
local Item_VFace = "face_adjust_VFace"

-- runtime
local EPSC = 0.001

local organParam =
{
 0.08,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
 -0.2,
    0,
-0.01,
    0,
    0,
    0,
    0,
    0,
    0,
 -0.2,
    2,
    0
}

local organParamRange =
{
    {-0.18,  0.18}, -- far eye
    {    0,  0.14}, -- zoom eye
    {    0,     0}, -- rotate eye
    {  0.2,  -0.2}, -- move eye
    {    0, -0.14}, -- zoom nose
    { 0.28, -0.28}, -- move nose
    { 0.36, -0.36}, -- move mouth
    { 0.12, -0.12}, -- zoom mouth
    { 0.14,  -0.2}, -- move chin
    {  0.2,  -0.2}, -- zoom forehead
    {    0,     0}, -- zoom face
    {    0,  -0.2}, -- cut face
    {    0, -0.07}, -- small face
    {    0,  -0.2}, -- jawbone
    {    0,  -0.2}, -- cheek bone
    {    0, -0.12}, -- mouth corner
    {    0,  -0.2}, -- corner eye
    {    0,     0}, -- lip enhance
    {  0.2,  -0.2}, -- pointy chin
    {    0,     0}, -- temple
    {    0,     0}, -- eye type
    {    0,  -1.4}, -- vface
}

-- param range in engine
local organMaxInEigine =
{
        3, -- far eye, set default param max value to 3
      0.2, -- zoom eye
        3, -- rotate eye
      0.2, -- move eye
      0.2, -- zoom nose
     0.28, -- move nose
     0.36, -- move mouth
      0.2, -- zoom mouth
      0.2, -- move chin
      0.2, -- zoom forehead
        3, -- zoom face
      0.2, -- cut face
      0.2, -- small face
      0.2,-- jawbone
      0.3, -- cheek bone
      0.2, -- mouse corner
      0.2, -- corner eye
        3, --  lip enhance
      0.2, -- pointy chin
        3, -- temple
        3, -- eye type
        2, -- vface
}

local function clamp(val, min, max)
    return math.max(math.min(val, max), min)
end

local function clampParam(value, index)
    -- return clamp(value, -organMaxInEigine[index], organMaxInEigine[index])
    return value
end

local function getSmallItemValueBy(percentage, index)
    if percentage < 0 then
        return -percentage * organParamRange[index][1]
    else
        return percentage * organParamRange[index][2]
    end
end

function reshape.new(construct, ...)
    local self = setmetatable({}, reshape)

    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.faceAdjustMaps = {}

    self.intensityKeys = {
        Item_TotalFace,
        Item_EyeSpacing,
        Item_EnlargeEye,
        Item_MoveEye,
        Item_Nose,
        Item_MoveNose,
        Item_MoveMouth,
        Item_ZoomMouth,
        Item_Chin,
        Item_Forehead,
        Item_CutFace,
        Item_SmallFace,
        Item_ZoomJawbone,
        Item_ZoomCheekbone,
        Item_MouthCorner,
        Item_CornerEye,
        Item_ChinSharp,
        Item_VFace
    }

    return self
end

function reshape:onStart(comp, script)
    local scene = comp.entity.scene

    local curScriptSystem = scene:getSystem("ScriptSystem")
    curScriptSystem:clearAllEventType()
    curScriptSystem:addEventType(Amaz.AppEventType.SetEffectIntensity)

    self.scriptProps = comp.properties
    self.reshapeEntities = {}
    self.reshapeComps = {}
    for i = 0, self.maxFaceNum - 1 do
        self.reshapeEntities[i] = scene:findEntityBy("reshape_" .. i + 1)
        self.reshapeComps[i] = self.reshapeEntities[i]:getComponent("FaceReshape")
    end
    -- Amaz.LOGS('beauty24','--------------scene = ' .. tostring(scene))
end

function reshape:getValue(id, key, default)
    local vec = self.faceAdjustMaps[key]
    if vec == nil then
        return default
    end
    local intensity = default
    local inputSize = vec:size()
    local hit = false
    local val = default
    for i = 0, inputSize - 1 do
        local inputMap = vec:get(i)
        if id == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
            intensity = inputMap:get(INTENSITY_TAG)
            hit = true
        elseif -1 == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
            val = inputMap:get(INTENSITY_TAG)
        end
    end

    if hit == false then
        intensity = val
    end

    return intensity
end

function reshape:onUpdate(comp, deltaTime)
    -- get face info by size order
    self:updateFaceInfoBySize()

    -- update face with valid track id
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index

        local intensityTotalFace = 0
        local intensityEyeSpacing = 0
        local intensityEnlargeEye = 0
        local intensityMoveEye = 0
        local intensityNose = 0
        local intensityMoveNose = 0
        local intensityMoveMouth = 0
        local intensityZoomMouth = 0
        local intensityChin = 0
        local intensityForehead = 0
        local intensityCutFace = 0
        local intensitySmallFace = 0
        local intensityZoomJawbone = 0
        local intensityZoomCheekbone = 0
        local intensityMouthCorner = 0
        local intensityCornerEye = 0
        local intensityChinSharp = 0
        local intensityVFace = 0
        if id ~= -1 and i <= self.maxDisplayNum then
            intensityTotalFace = self:getValue(id, Item_TotalFace, 0)
            intensityEyeSpacing = self:getValue(id, Item_EyeSpacing, 0) * 4.0
            intensityEnlargeEye = self:getValue(id, Item_EnlargeEye, 0)
            intensityMoveEye = self:getValue(id, Item_MoveEye, 0) * 3
            intensityNose = self:getValue(id, Item_Nose, 0)
            intensityMoveNose = self:getValue(id, Item_MoveNose, 0)
            intensityMoveMouth = self:getValue(id, Item_MoveMouth, 0) * 2.0
            intensityZoomMouth = self:getValue(id, Item_ZoomMouth, 0) * 7.0
            intensityChin = self:getValue(id, Item_Chin, 0) * 2.0
            intensityForehead = self:getValue(id, Item_Forehead, 0) * 4.0
            intensityCutFace = self:getValue(id, Item_CutFace, 0)
            intensitySmallFace = self:getValue(id, Item_SmallFace, 0)
            intensityZoomJawbone = self:getValue(id, Item_ZoomJawbone, 0) * 1.5
            intensityZoomCheekbone =self:getValue(id, Item_ZoomCheekbone, 0) * 1.5
            intensityMouthCorner = self:getValue(id, Item_MouthCorner, 0)
            intensityCornerEye = self:getValue(id, Item_CornerEye, 0) * 2.0
            intensityChinSharp = self:getValue(id, Item_ChinSharp, 0)
            intensityVFace = self:getValue(id, Item_VFace, 0)
        end
        if math.abs(intensityTotalFace) > EPSC or
           math.abs(intensityEyeSpacing) > EPSC or
           math.abs(intensityEnlargeEye) > EPSC or
           math.abs(intensityMoveEye) > EPSC or
           math.abs(intensityNose) > EPSC or
           math.abs(intensityMoveNose) > EPSC or
           math.abs(intensityMoveMouth) > EPSC or
           math.abs(intensityZoomMouth) > EPSC or
           math.abs(intensityChin) > EPSC or
           math.abs(intensityForehead) > EPSC or
           math.abs(intensityCutFace) > EPSC or
           math.abs(intensitySmallFace) > EPSC or
           math.abs(intensityZoomJawbone) > EPSC or
           math.abs(intensityZoomCheekbone) > EPSC or
           math.abs(intensityMouthCorner) > EPSC or
           math.abs(intensityCornerEye) > EPSC or
           math.abs(intensityChinSharp) > EPSC or
           math.abs(intensityVFace) > EPSC
        then
            self.reshapeEntities[index].visible = true
            local degrees = self.reshapeComps[index].params.degrees
            -- local val = clampParam(organParam[ 1]*intensityTotalFace + getSmallItemValueBy(intensityEyeSpacing, 1), 1)
            degrees:set( 0, clampParam(organParam[ 1]*intensityTotalFace + getSmallItemValueBy(intensityEyeSpacing, 1), 1))
            degrees:set( 1, clampParam(organParam[ 2]*intensityTotalFace + getSmallItemValueBy(intensityEnlargeEye, 2), 2))
            degrees:set( 2, clampParam(organParam[ 3]*intensityTotalFace, 3))
            degrees:set( 3, clampParam(organParam[ 4]*intensityTotalFace + getSmallItemValueBy(intensityMoveEye, 4), 4))
            degrees:set( 4, clampParam(organParam[ 5]*intensityTotalFace + getSmallItemValueBy(intensityNose, 5), 5))
            degrees:set( 5, clampParam(organParam[ 6]*intensityTotalFace + getSmallItemValueBy(intensityMoveNose, 6), 6))
            degrees:set( 6, clampParam(organParam[ 7]*intensityTotalFace + getSmallItemValueBy(intensityMoveMouth, 7), 7))
            degrees:set( 7, clampParam(organParam[ 8]*intensityTotalFace + getSmallItemValueBy(intensityZoomMouth, 8), 8))
            degrees:set( 8, clampParam(organParam[ 9]*intensityTotalFace + getSmallItemValueBy(intensityChin, 9), 9))
            degrees:set( 9, clampParam(organParam[10]*intensityTotalFace + getSmallItemValueBy(intensityForehead, 10), 10))
            degrees:set(10, clampParam(organParam[11]*intensityTotalFace, 11))
            degrees:set(11, clampParam(organParam[12]*intensityTotalFace + getSmallItemValueBy(intensityCutFace, 12), 12))
            degrees:set(12, clampParam(organParam[13]*intensityTotalFace + getSmallItemValueBy(intensitySmallFace, 13), 13))
            degrees:set(13, clampParam(organParam[14]*intensityTotalFace + getSmallItemValueBy(intensityZoomJawbone, 14), 14))
            degrees:set(14, clampParam(organParam[15]*intensityTotalFace + getSmallItemValueBy(intensityZoomCheekbone, 15), 15))
            degrees:set(15, clampParam(organParam[16]*intensityTotalFace + getSmallItemValueBy(intensityMouthCorner, 16), 16))
            degrees:set(16, clampParam(organParam[17]*intensityTotalFace + getSmallItemValueBy(intensityCornerEye, 17), 17))
            degrees:set(17, clampParam(organParam[18]*intensityTotalFace, 18))
            degrees:set(18, clampParam(organParam[19]*intensityTotalFace + getSmallItemValueBy(intensityChinSharp, 19), 19))
            degrees:set(19, clampParam(organParam[20]*intensityTotalFace, 20))
            degrees:set(21, clampParam(organParam[22]*intensityTotalFace + getSmallItemValueBy(intensityVFace, 22), 22))
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

function reshape:setFaceAdjustMaps(inputId, inputMap)
    local lastMaps = self.faceAdjustMaps[inputId]
    if lastMaps==nil then
        self.faceAdjustMaps[inputId] = inputMap
        return
    end
    local keys = inputMap:getVectorKeys()
    for i = 0, keys:size()-1 do
        local key = keys:get(i)
        lastMaps:set(key, inputMap:get(key))
    end
    self.faceAdjustMaps[inputId] = lastMaps
end

function reshape:hitKey(key)
    for i = 1, #self.intensityKeys do
        if key == self.intensityKeys[i] then
            return true
        end
    end
    return false
end

function reshape:handleIntensityEvent(comp, event)
    local key = event.args:get(0)
    if self:hitKey(key) then
        self.faceAdjustMaps[key] = event.args:get(1)
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
            faceSize = faceRect.width * faceRect.height
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

exports.reshape = reshape
return exports