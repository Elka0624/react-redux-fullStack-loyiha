local exports = exports or {}
local Face3DSystem = Face3DSystem or {}
Face3DSystem.__index = Face3DSystem

local FACE_ID = "id"
local INTENSITY_TAG = "intensity"

local Item_Big = "blendShape1._big"
local Item_Small = "blendShape1._small"
local Item_BiGen_Low = "blendShape1._bigen_low"
local Item_BiGen_High = "blendShape1._bigen_high"
local Item_BiLiang_Low = "blendShape1._biliang_low"
local Item_BiLiang_High = "blendShape1._biliang_high"
local Item_BiTou_Max = "blendShape1._bitou_max"
local Item_BiTou_Min = "blendShape1._bitou_min"
local Item_BiYi_Max = "blendShape1._biyi_max"
local Item_BiYi_min = "blendShape1._biyi_min"

local NOSE_SIZE_EVENT_TAG = "face_adjust_3DNose_Big"
local NOSE_NASION_EVENT_TAG = "face_adjust_3DNose_Nasion"
local NOSE_BRIDGE_EVENT_TAG = "face_adjust_3DNose_Bridge"
local NOSE_GUARD_EVENT_TAG = "face_adjust_3DNose_Guard"
local NOSE_TIP_EVENT_TAG = "face_adjust_3DNose_Tip"

function Face3DSystem.new(construct, ...)
    local self = setmetatable({}, Face3DSystem)

    self.morpherData = nil
    self.entities = {}
    self.noseAdjustMaps = {}

    self.intensityKeys = {
        NOSE_SIZE_EVENT_TAG,
        NOSE_NASION_EVENT_TAG,
        NOSE_BRIDGE_EVENT_TAG,
        NOSE_GUARD_EVENT_TAG,
        NOSE_TIP_EVENT_TAG
    }
    self.defaultIntensity = 0.0

    self.maxFaceNum = 6
    self.maxDisplayNum = 5

    self.morphComp = {}
    self.renderComp = {}
    self.fxaaEntities = {}
    self.fxaaRenderComp = {}
    self.bsName = {}
    self.channelsCount = 0
    self.indicesCount = 0
    self.offsetPos = {}
    self.newChannel = 'New' -- new blendshape

    self.tempMorphComp = {}
    self.tempFacePos = {}
    self.tempFaceNormals = {}
    self.tempIndices = {}
    self.tempUVs = {}
    self.tempKeyPos = {}
    self.tempOriginKeyPos = {}

    self.keyVertexsId = {   444, 275, 203, 202, 810, 881, 1017,
                            445, 354, 200, 201, 809, 957, 1018,
                            446, 355, 356, 360, 958, 959, 1019,
                            358, 357, 359, 361, 962, 960, 961,
                            114, 112, 109, 108, 721, 723, 725 }

    self.addVertexData = {
        [1] = { p = { 202, 201, 360, 361 }, n = { 201, 360 } },
        [2] = { p = { 201, 360, 361, 108 }, n = { 360, 361 } },
        [3] = { p = { 203, 200, 356, 359 }, n = { 200, 356 } },
        [4] = { p = { 200, 356, 359, 109 }, n = { 356, 359 } },
        [5] = { p = { 810, 809, 958, 962 }, n = { 809, 958 } },
        [6] = { p = { 809, 958, 962, 721 }, n = { 958, 962 } },
        [7] = { p = { 354, 200, 201, 809 }, n = { 200, 201 } },
        [8] = { p = { 200, 201, 809, 957 }, n = { 201, 809 } },
        [9] = { p = { 357, 359, 361, 962 }, n = { 359, 361 } },
        [10] = { p = { 359, 361, 962, 960 }, n = { 361, 962 } },
        [11] = { p = { 355, 356, 360, 958 }, n = { 356, 360 } },
        [12] = { p = { 356, 360, 958, 959 }, n = { 360, 958 } },
        [13] = { p = { 275, 200, 360, 962 }, n = { 200, 360 } },
        [14] = { p = { 881, 809, 360, 359 }, n = { 809, 360 } },
        [15] = { p = { 809, 360, 359, 112 }, n = { 360, 359 } },
        [16] = { p = { 200, 360, 962, 723 }, n = { 360, 962 } },
        [17] = { p = { 275, 354, 355, 357 }, n = { 354, 355 } },
        [18] = { p = { 354, 355, 357, 112 }, n = { 355, 357 } },
        [19] = { p = { 881, 957, 959, 960 }, n = { 957, 959 } },
        [20] = { p = { 957, 959, 960, 723 }, n = { 959, 960 } },
        [21] = { p = { 445, 354, 200, 201 }, n = { 354, 200 } },
        [22] = { p = { 201, 809, 957, 1018 }, n = { 809, 957 } },
        [23] = { p = { 358, 357, 359, 361 }, n = { 357, 359 } },
        [24] = { p = { 361, 962, 960, 961 }, n = { 962, 960 } },
        [25] = { p = { 446, 355, 356, 360 }, n = { 355, 356 } },
        [26] = { p = { 360, 958, 959, 1019 }, n = { 958, 959 } },
        [27] = { p = { 444, 354, 356, 361 }, n = { 354, 356 } },
        [28] = { p = { 1017, 957, 958, 361 }, n = { 957, 958 } },
        [29] = { p = { 201, 356, 357, 114 }, n = { 356, 357 } },
        [30] = { p = { 201, 958, 960, 725 }, n = { 958, 960 } }
    }
    self.addVertexCount = #self.addVertexData

    self.addInIndicesData = {
        [1] = { i = { 521, 520 }, v = { 360, 200 }, a = { 7, 13, 1 } },
        [2] = { i = { 516, 518 }, v = { 200, 360 }, a = { 11, 13, 3 } },
        [3] = { i = { 533, 532 }, v = { 361, 356 }, a = { 11, 15, 2 } },
        [4] = { i = { 528, 530 }, v = { 356, 361 }, a = { 9, 15, 4 } },
        [5] = { i = { 1574, 1573 }, v = { 809, 360 }, a = { 1, 14, 8 } },
        [6] = { i = { 1569, 1571 }, v = { 360, 809 }, a = { 5, 14, 12 } },
        [7] = { i = { 1586, 1585 }, v = { 958, 361 }, a = { 2, 16, 12 } },
        [8] = { i = { 1581, 1583 }, v = { 361, 958 }, a = { 6, 16, 10 } },
        [9] = { i = { 497, 496 }, v = { 356, 354 }, a = { 21, 27, 3 } },
        [10] = { i = { 492, 494 }, v = { 354, 356 }, a = { 25, 27, 17 } },
        [11] = { i = { 515, 514 }, v = { 359, 355 }, a = { 25, 29, 4 } },
        [12] = { i = { 510, 512 }, v = { 355, 359 }, a = { 23, 29, 18 } },
        [13] = { i = { 1550, 1549 }, v = { 957, 958 }, a = { 5, 28, 22 } },
        [14] = { i = { 1545, 1547 }, v = { 958, 957 }, a = { 19, 28, 26 } },
        [15] = { i = { 1568, 1567 }, v = { 959, 962 }, a = { 6, 30, 26 } },
        [16] = { i = { 1563, 1565 }, v = { 962, 959 }, a = { 20, 30, 24 } }
    }

    self.addOutIndicesData = {
        [1] = { i = { 105 }, v = { 202, 200 }, a = { 7 } },
        [2] = { i = { 1163 }, v = { 809, 202 }, a = { 8 } },
        [3] = { i = { 1918 }, v = { 959, 1018 }, a = { 19 } },
        [4] = { i = { 1922 }, v = { 960, 1019 }, a = { 20 } },
        [5] = { i = { 1579 }, v = { 361, 721 }, a = { 10 } },
        [6] = { i = { 527 }, v = { 109, 361 }, a = { 9 } },
        [7] = { i = { 906 }, v = { 446, 357 }, a = { 18 } },
        [8] = { i = { 905 }, v = { 445, 355 }, a = { 17 } },
        [9] = { i = { 485 }, v = { 203, 354 }, a = { 21 } },
        [10] = { i = { 1537 }, v = { 957, 810 }, a = { 22 } },
        [11] = { i = { 1561 }, v = { 962, 723 }, a = { 24 } },
        [12] = { i = { 509 }, v = { 112, 359 }, a = { 23 } }
    }

    return self
end

function Face3DSystem:Init()
    for i = 0, self.maxFaceNum - 1 do

        local morphComp = self.morphComp[i]
        local morph = morphComp:getMorpher()

        if i == 0 then
            self.channelsCount = morph:getMorpherChannelsCount()
            local vertexsId = self.keyVertexsId
            local keys = morphComp.channelWeights:getVectorKeys()
            local keyCount = keys:size()
            for k = 1, keyCount do
                self.bsName[k] = keys:get(keyCount - k)
            end

            for t = 1, #vertexsId do

                local vertexId = vertexsId[t]
                self.offsetPos[vertexId] = {}
                for n = 1, self.channelsCount do

                    local ch = morph.channels:get(n-1)
                    local chName = ch.name
                    local target = ch.targets:get(0)
                    local indices = target.indices
                    local data = target.offsetdata

                    local ids = -1
                    local indicesCount = indices:size()
                    for c = 0, indicesCount - 1 do
                        local indice = indices:get(c)
                        if indice == vertexId then
                            ids = c
                            break
                        end
                    end

                    self.offsetPos[vertexId][chName] = Amaz.Vector3f(0.0,0.0,0.0)
                    if ids > -1 then
                        local id = ids * 3
                        local px = data:get(id)
                        local py = data:get(id + 1)
                        local pz = data:get(id + 2)
                        self.offsetPos[vertexId][chName] = Amaz.Vector3f(px,py,pz)
                    end
                end
            end
        end

        local chs = morph.channels
        local ch = chs:get(0):clone() -- new channel
        ch.name = self.newChannel
        local target = ch.targets:get(0)
        local indices = target.indices
        local offsetdata = target.offsetdata
        indices:resize(self.addVertexCount)
        offsetdata:resize(self.addVertexCount * 3)
        target.indices = indices
        target.offsetdata = offsetdata
        chs:pushBack(ch)
        morph.channels = chs
    end

    for i = 0, self.maxFaceNum - 1 do

        local renderMesh = self.renderComp[i].mesh
        local subMesh = renderMesh:getSubMesh(0)
        local indices = subMesh.indices16

        if i == 0 then
            self.indicesCount = subMesh.indicesCount
        end

        indices:resize(self.indicesCount + self.addVertexCount * 6)
        renderMesh:getSubMesh(0).indices16 = indices
        renderMesh.morphers:set(0, self.morphComp[i]:getMorpher())
        subMesh.indices16 = indices
        self.morphComp[i].basemesh = nil
        self.morphComp[i].basemesh = renderMesh
    end
end

function Face3DSystem:onStart(sys, script)
    local scene = sys.scene

    local curScriptSystem = scene:getSystem("ScriptSystem")
    curScriptSystem:clearAllEventType()
    curScriptSystem:addEventType(Amaz.AppEventType.SetEffectIntensity)

    -- local outputRT = scene:getOutputRenderTexture()
    -- outputRT.attachment = Amaz.RenderTextureAttachment.NONE

    self.channelWeights = {}

    for i = 0, self.maxFaceNum - 1 do
        self.entities[i] = scene:findEntityBy("3DFaceBS" .. i)
        self.entities[i].visible = false
        self.morphComp[i] = self.entities[i]:getComponent("MorpherComponent")
        self.renderComp[i] = self.entities[i]:getComponent("MeshRenderer")
        self.channelWeights[i] = self.morphComp[i].channelWeights

        self.fxaaEntities[i] = scene:findEntityBy("3DFaceFXAA" .. i)
        self.fxaaEntities[i].visible = false
        self.fxaaRenderComp[i] = self.fxaaEntities[i]:getComponent("MeshRenderer")
    end

    self.morpherData = scene:findEntityBy("MorpherData"):getComponent("TableComponent").table

    self:Init()
end

function Face3DSystem:updateMesh(faceMeshInfo, i)
    if self.maxFaceNum <= i then
        Amaz.LOGS("beauty24", "self.maxFaceNum <= i, i = " .. tostring(i))
        return false
    end

    local faceMVP = faceMeshInfo.mvp
    local faceModel = faceMeshInfo.modelMatrix
    local facePos = faceMeshInfo.vertexes
    local faceNormals = faceMeshInfo.normals
    local renderProps = self.renderComp[i].props
    local renderMesh = self.renderComp[i].mesh
    local morphComp = self.morphComp[i]
    local subMesh = renderMesh:getSubMesh(0)
    local indices = subMesh.indices16
    local uvs = renderMesh:getUvArray(0)

    local posCount = facePos:size()
    if posCount < 1220 then -- 1495
        Amaz.LOGS("beauty24", "posCount < 1220, posCount = " .. tostring(posCount))
        return false
    end
    local indicesCount = self.indicesCount
    facePos:resize(posCount + self.addVertexCount)
    faceNormals:resize(posCount + self.addVertexCount)
    uvs:resize(posCount + self.addVertexCount)

    self.tempMorphComp = morphComp
    self.tempFacePos = facePos
    self.tempFaceNormals = faceNormals
    self.tempIndices = indices
    self.tempUVs = uvs
    self:calNewKeyPos()
    self:addAllNewVertex(posCount, indicesCount)

    renderProps:setMatrix("u_Model", faceModel)
    renderProps:setMatrix("u_MVP", faceMVP)
    renderMesh:setVertexArray(facePos)
    renderMesh:setNormalArray(faceNormals)
    renderMesh.morphers:set(0, morphComp:getMorpher())
    renderMesh:getSubMesh(0).indices16 = indices
    renderMesh:setUvArray(0, uvs)
    morphComp.basemesh = renderMesh

    local fxaaRenderProps = self.fxaaRenderComp[i].props
    local fxaaRenderMesh = self.fxaaRenderComp[i].mesh
    fxaaRenderProps:setMatrix("u_Model", faceModel)
    fxaaRenderProps:setMatrix("u_MVP", faceMVP)
    fxaaRenderMesh:setVertexArray(facePos)
    fxaaRenderMesh:setNormalArray(faceNormals)

    return true
end

function Face3DSystem:isSkip(id)
    for i = 1, #self.intensityKeys do
        local key = self.intensityKeys[i]
        local vec = self.noseAdjustMaps[key]
        local hit = false
        local val = self.defaultIntensity
        if vec ~= nil then
            local inputSize = vec:size()
            for j = 0, inputSize - 1 do
                local inputMap = vec:get(j)
                if id == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
                    hit = true
                    if math.abs(self.defaultIntensity - inputMap:get(INTENSITY_TAG)) > 0.0001 then
                        return false
                    end
                elseif -1 == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
                    val = inputMap:get(INTENSITY_TAG)
                end
            end
            if hit == false then
                if math.abs(self.defaultIntensity - val) > 0.0001 then
                    return false
                end
            end
        end
    end
    return true
end

function Face3DSystem:processOneFace(faceInfo, faceCount, result)
    local id = faceInfo.id
    local index = faceInfo.index

    self.entities[index].visible = false
    self.fxaaEntities[index].visible = false

    if id == -1 or index >= faceCount then
        return
    end

    local faceBaseInfo = result:getFaceBaseInfo(index)
    local faceMeshInfo = result:getFaceMeshInfo(index)

    if faceMeshInfo == nil or faceBaseInfo == nil then
        return
    end

    local weights = self:parseChannelWeights(id)
    local channelWeights = self.channelWeights[index]

    local faceModel = faceMeshInfo.modelMatrix
    local rotate = Amaz.Quaternionf()
    faceModel:getDecompose(Amaz.Vector3f(), Amaz.Vector3f(), rotate)
    local euler = rotate:quaternionToEuler()
    local x = euler.x / 3.14 * 180.0
    local y = euler.y / 3.14 * 180.0
    local z = euler.z / 3.14 * 180.0
    if x > 180 then x = math.abs(x - 360) end
    if y > 180 then y = math.abs(y - 360) end
    if z > 180 then z = math.abs(z - 360) end

    local keys = channelWeights:getVectorKeys()
    for k = 0, keys:size() - 1 do
        local key = keys:get(k)

        if self.morpherData:has(key) == true and weights:has(key) == true then
            local ratios = self.morpherData:get(key)
            local pitch1 = ratios:get(0)
            local value1 = ratios:get(1)
            local pitch2 = ratios:get(2)
            local value2 = ratios:get(3)
            local pitch3 = ratios:get(4)
            local value3 = ratios:get(5)
            local pitch4 = ratios:get(6)
            local value4 = ratios:get(7)

            local yaw1 = ratios:get(8)
            local value1y = ratios:get(9)
            local yaw2 = ratios:get(10)
            local value2y = ratios:get(11)
            local yaw3 = ratios:get(12)
            local value3y = ratios:get(13)
            local yaw4 = ratios:get(14)
            local value4y = ratios:get(15)

            if x > pitch4 or y > yaw4 then
                if x > pitch4 and y > yaw4 then
                    channelWeights:set(key, weights:get(key) * math.min(value4, value4y))
                elseif x > pitch4 then
                    channelWeights:set(key, weights:get(key) * value4)
                else
                    channelWeights:set(key, weights:get(key) * value4y)
                end
            elseif x > pitch3 or y > yaw3 then
                local ratio = 0.0
                if x > pitch3 and y > yaw3 then
                    local ratiop = value3 + (x - pitch3) / (pitch4 - pitch3) * (value4 - value3)
                    local ratioy = value3y + (x - pitch3) / (pitch4 - pitch3) * (value4y - value3y)
                    ratio = math.min(ratiop, ratioy)
                elseif x > pitch3 then
                    ratio = value3 + (x - pitch3) / (pitch4 - pitch3) * (value4 - value3)
                else
                    ratio = value3y + (y - yaw3) / (yaw4 - yaw3) * (value4y - value3y)
                end
                channelWeights:set(key, weights:get(key) * ratio)
            elseif x > pitch2 or y > yaw2 then
                local ratio = 0.0
                if x > pitch2 and y > yaw3 then
                    local ratiop = value2 + (x - pitch2) / (pitch3 - pitch2) * (value3 - value2)
                    local ratioy = value2y + (x - pitch2) / (pitch3 - pitch2) * (value3y - value2y)
                    ratio = math.min(ratiop, ratioy)
                elseif x > pitch2 then
                    ratio = value2 + (x - pitch2) / (pitch3 - pitch2) * (value3 - value2)
                else
                    ratio = value2y + (y - yaw2) / (yaw3 - yaw2) * (value3y - value2y)
                end
                channelWeights:set(key, weights:get(key) * ratio)
            elseif x > pitch1 or y > yaw1 then
                local ratio = 0.0
                if x > pitch1 and y > yaw1 then
                    local ratiop = value1 + (x - pitch1) / (pitch2 - pitch1) * (value2 - value1)
                    local ratioy = value1y + (x - pitch1) / (pitch2 - pitch1) * (value2y - value1y)
                    ratio = math.min(ratiop, ratioy)
                elseif x > pitch1 then
                    ratio = value1 + (x - pitch1) / (pitch2 - pitch1) * (value2 - value1)
                else
                    ratio = value1y + (y - yaw1) / (yaw2 - yaw1) * (value2y - value1y)
                end
                channelWeights:set(key, weights:get(key) * ratio)
            else
                channelWeights:set(key, weights:get(key) * math.min(value1, value1y))
            end
        elseif weights:has(key) == true then
            channelWeights:set(key, weights:get(key))
        end
    end

    local flag = self:updateMesh(faceMeshInfo, index)
    if flag == false then
        return
    end

    self.entities[index].visible = true
    self.fxaaEntities[index].visible = true
end

function Face3DSystem:updateMorpher()
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()

    for i = 1, self.maxFaceNum do
        if i <= self.maxDisplayNum then
            self:processOneFace(self.faceInfoBySize[i], faceCount, result)
        end
    end
end

function Face3DSystem:updateFaceInfoBySize()
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

function Face3DSystem:onUpdate(sys, deltaTime)
    self:updateFaceInfoBySize()
    self:updateMorpher()
end

function Face3DSystem:hitKey(key)
    for i = 1, #self.intensityKeys do
        if key == self.intensityKeys[i] then
            return true
        end
    end
    return false
end

function Face3DSystem:processMorpherEvent(event)
    local key = event.args:get(0)
    if self:hitKey(key) then
        self.noseAdjustMaps[key] = event.args:get(1)
    end
end

function Face3DSystem:parseChannelWeights(inputId)
    local weights = Amaz.Map()

    for i = 1, #self.intensityKeys do
        local key = self.intensityKeys[i]
        local intensity = self.defaultIntensity

        local vec = self.noseAdjustMaps[key]
        local val = self.defaultIntensity
        local hit = false
        if vec ~= nil then
            local inputSize = vec:size()
            for j = 0, inputSize - 1 do
                local inputMap = vec:get(j)
                if inputId == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
                    intensity = inputMap:get(INTENSITY_TAG)
                    hit = true
                elseif -1 == inputMap:get(FACE_ID) and inputMap:has(INTENSITY_TAG) then
                    val = inputMap:get(INTENSITY_TAG)
                end
            end
        end

        if hit == false then
            intensity = val
        end

        intensity = intensity * 2.0

        if NOSE_SIZE_EVENT_TAG == key then
            if intensity < 0.0 then
                weights:set(Item_Big, math.abs(intensity))
                weights:set(Item_Small, 0.0)
            else
                weights:set(Item_Small, intensity)
                weights:set(Item_Big, 0.0)
            end
        elseif NOSE_NASION_EVENT_TAG == key then
            if intensity < 0.0 then
                weights:set(Item_BiGen_Low, math.abs(intensity))
                weights:set(Item_BiGen_High, 0.0)
            else
                weights:set(Item_BiGen_High, intensity)
                weights:set(Item_BiGen_Low, 0.0)
            end
        elseif NOSE_BRIDGE_EVENT_TAG == key then
            intensity = intensity / 2.0
            weights:set(Item_BiLiang_High, intensity)
            weights:set(Item_BiLiang_Low, 0.0)
        elseif NOSE_GUARD_EVENT_TAG == key then
            if intensity < 0.0 then
                weights:set(Item_BiTou_Max, math.abs(intensity))
                weights:set(Item_BiTou_Min, 0.0)
            else
                weights:set(Item_BiTou_Min, intensity)
                weights:set(Item_BiTou_Max, 0.0)
            end
        elseif NOSE_TIP_EVENT_TAG == key then
            if intensity < 0.0 then
                weights:set(Item_BiYi_Max, math.abs(intensity))
                weights:set(Item_BiYi_min, 0.0)
            else
                weights:set(Item_BiYi_min, intensity)
                weights:set(Item_BiYi_Max, 0.0)
            end
        end
    end

    return weights
end

function Face3DSystem:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:processMorpherEvent(event)
    end
end

function Face3DSystem:Saturate(x)
    return math.max(math.min(x, 1.0), 0.0)
end

function Face3DSystem:Lerp(a, b, t)
    t = self:Saturate(t)
    return (b - a) * t + a;
end

function Face3DSystem:CatmullRomPoint(t, p0, p1, p2, p3)
    local a = p1
    local b = (p2 - p0) * 0.5
    local c = (p0 * 2 - p1 * 5 + p2 * 4 - p3) * 0.5
    local d = (-p0 + p1 * 3 - p2 * 3 + p3) * 0.5
    return a + b * t + c * t * t + d * t * t * t
end

function Face3DSystem:getOffsetPos(morphComp, facePos, vertexId)
    local offsetPos = Amaz.Vector3f(0.0,0.0,0.0)
    local bsCount = #self.bsName
    for i = 1, bsCount do
        local name = self.bsName[i]
        local weight = morphComp:getChannelWeight(name)
        offsetPos = offsetPos + self.offsetPos[vertexId][name] * weight
    end
    local newPos = facePos:get(vertexId) + offsetPos
    return newPos
end

function Face3DSystem:getNewPos(vertexId)
    return self:getOffsetPos(self.tempMorphComp, self.tempFacePos, vertexId)
end

function Face3DSystem:calNewKeyPos()
    for i = 1, #self.keyVertexsId do
        local vid = self.keyVertexsId[i]
        self.tempKeyPos[vid] = self:getNewPos(vid)
        self.tempOriginKeyPos[vid] = self.tempFacePos:get(vid)
    end
end

function Face3DSystem:getLerpPos(vid0, vid1, vid2, vid3)
    local p0 = self.tempKeyPos[vid0]
    local p1 = self.tempKeyPos[vid1]
    local p2 = self.tempKeyPos[vid2]
    local p3 = self.tempKeyPos[vid3]
    local newPos = self:CatmullRomPoint(0.5, p0, p1, p2, p3)
    return newPos
end

function Face3DSystem:getLerpNor(vid1, vid2)
    local newNormal = Amaz.Vector3f.Normalize((self.tempFaceNormals:get(vid1) + self.tempFaceNormals:get(vid2))*0.5)
    return newNormal -- Amaz.Vector3f(0.0, 0.0, 0.0)
end

function Face3DSystem:getLerpUV(vid1, vid2)
    local newUV = (self.tempUVs:get(vid1) + self.tempUVs:get(vid2))*0.5
    return newUV
end

function Face3DSystem:getOriginLerpPos(vid1, vid2)
    return (self.tempOriginKeyPos[vid1] + self.tempOriginKeyPos[vid2]) * 0.5
end

function Face3DSystem:addNewVertex(keyId, posId)
    local data = self.addVertexData[keyId]

    local newPos = self:getLerpPos(data.p[1], data.p[2], data.p[3], data.p[4])
    self.tempFacePos:set(posId, newPos)

    local newNormal = self:getLerpNor(data.n[1], data.n[2])
    self.tempFaceNormals:set(posId, newNormal)
    local newUV = self:getLerpUV(data.n[1], data.n[2])
    self.tempUVs:set(posId, newUV)

    local morphComp = self.tempMorphComp
    local morph = morphComp:getMorpher()

    local ch = morph.channels:get(self.channelsCount) -- new channel
    local target = ch.targets:get(0)
    local indices = target.indices
    local offsetdata = target.offsetdata
    local originPos = self:getOriginLerpPos(data.n[1], data.n[2])
    morphComp:setChannelWeight(self.newChannel,1.0)
    local offsetpos = self.tempFacePos:get(posId) - originPos
    local IndicesId = keyId - 1
    local dataId = (keyId - 1) * 3
    indices:set(IndicesId, posId)
    offsetdata:set(dataId, offsetpos.x)
    offsetdata:set(dataId + 1, offsetpos.y)
    offsetdata:set(dataId + 2, offsetpos.z)
    target.indices = indices
    target.offsetdata = offsetdata

    self.tempFacePos:set(posId, originPos)
end

function Face3DSystem:addNewInIndices(keyId, posId, indicesId)
    local data = self.addInIndicesData[keyId]
    local v1 = data.v[1]
    local v2 = data.v[2]
    local a1 = data.a[1] + (posId - 1)
    local a2 = data.a[2] + (posId - 1)
    local a3 = data.a[3] + (posId - 1)

    self.tempIndices:set(data.i[1], a3)
    self.tempIndices:set(data.i[2], a1)

    self.tempIndices:set(indicesId, v1)
    self.tempIndices:set(indicesId+1, a3)
    self.tempIndices:set(indicesId+2, a2)

    self.tempIndices:set(indicesId+3, a1)
    self.tempIndices:set(indicesId+4, a2)
    self.tempIndices:set(indicesId+5, a3)

    self.tempIndices:set(indicesId+6, a2)
    self.tempIndices:set(indicesId+7, a1)
    self.tempIndices:set(indicesId+8, v2)
end

function Face3DSystem:addNewOutIndices(keyId, posId, indicesId)
    local data = self.addOutIndicesData[keyId]
    local v1 = data.v[1]
    local v2 = data.v[2]
    local a1 = data.a[1] + (posId - 1)

    self.tempIndices:set(data.i[1], a1)

    self.tempIndices:set(indicesId, v1)
    self.tempIndices:set(indicesId+1, v2)
    self.tempIndices:set(indicesId+2, a1)
end

function Face3DSystem:addAllNewVertex(posId, indicesId)
    for i = 1, self.addVertexCount do
        self:addNewVertex(i, posId + (i - 1))
    end

    for i = 1, #self.addInIndicesData do
        self:addNewInIndices(i, posId, indicesId + (i - 1) * 9)
    end
    indicesId = indicesId + #self.addInIndicesData * 9

    for i = 1, #self.addOutIndicesData do
        self:addNewOutIndices(i, posId, indicesId + (i - 1) * 3)
    end
end

exports.Face3DSystem = Face3DSystem

return exports

