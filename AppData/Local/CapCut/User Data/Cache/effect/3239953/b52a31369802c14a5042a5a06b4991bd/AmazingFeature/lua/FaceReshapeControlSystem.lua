local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local EPSC = 0.001
local INTENSITY_TAG = "intensity"

local nameMap = {
    -- Nose
    face_adjust_nose = "NoseSize",
    face_adjust_nose_bridge = "NoseBridge",
    face_adjust_nose_position = "NosePosition",
    face_adjust_nose_root = "NoseRoot",
    face_adjust_nose_tip = "NoseTip",
    face_adjust_nose_wing = "NoseWing",
    -- eye
    face_adjust_outer_corner = "EyeOuterCorner",
    face_adjust_inner_corner = "EyeInnerCorner",
    face_adjust_outer_corner_inout = "EyeOuterCornerInout",
    face_adjust_eye_width = "EyeWidth",
    face_adjust_pupil = "EyePupil",
    face_adjust_eye_height = "EyeHeight",
    face_adjust_eye = "EyeSize",
    face_adjust_lower_eyelid = "EyeLowerEyelid",
    face_adjust_eye_position = "EyePosition",
    face_adjust_eye_distance = "EyeDistance",
    -- brow
    face_adjust_brow_ridge = "BrowRidge",
    face_adjust_brow_size = "BrowSize",
    face_adjust_brow_position = "BrowPosition",
    face_adjust_brow_tilt = "BrowTilt",
    face_adjust_brow_width = "BrowWidth",
    face_adjust_brow_distance = "BrowDistance",
    -- mouth
    face_adjust_mouse_width = "MouseWidth",
    face_adjust_mouse_corner = "MouseCorner",
    face_adjust_mouse = "MouseSize",
    face_adjust_mouse_position = "MousePosition",
    face_adjust_under_lip = "UnderLip",
    face_adjust_upper_lip = "UpperLip",
    face_adjust_lip_line = "LipLine",
    -- face
    face_adjust_temple = "FaceTemple",
    face_adjust_cheekbone = "FaceCheekbone",
    face_adjust_pointy_chin = "FacePointyChin",
    face_adjust_jaw = "FaceJaw",
    face_adjust_underjaw = "FaceUnderJaw",
    face_adjust_upper_atrium = "UpperAtrium",
    face_adjust_mid_atrium = "MidAtrium",
    face_adjust_lower_atrium = "LowerAtrium",
}


local exports = exports or {}
local FaceReshapeControlSystem = FaceReshapeControlSystem or {}
FaceReshapeControlSystem.__index = FaceReshapeControlSystem

function FaceReshapeControlSystem.new(construct, ...)
    local self = setmetatable({}, FaceReshapeControlSystem)
    self.entities = {}
    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.tmpOrder = 1
    self.renderOrderDict = {}
    self.faceAdjustMaps = {}
    local defaultMap = Amaz.Map()
    defaultMap:set(FACE_ID, -1)
    self.faceAdjustMaps[-1] = defaultMap
    return self
end

function FaceReshapeControlSystem:constructor()
end

function FaceReshapeControlSystem:onStart(sys)
    local curScriptSystem = sys.scene:getSystem("ScriptSystem")
    curScriptSystem:clearAllEventType()
    curScriptSystem:addEventType(Amaz.AppEventType.SetEffectIntensity)

    local entities = sys.scene.entities
    for i = 0, entities:size() - 1 do
        local entity = entities:get(i)
        -- table.insert(self.entities, entity)
        self.entities[entity.name] = entity
    end
end

function FaceReshapeControlSystem:onComponentAdded(sys, comp)
end

function  FaceReshapeControlSystem:onComponentRemoved(sys, comp)
end

function FaceReshapeControlSystem:getValue(id, key, default)
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

    if key ~= 'face_adjust_inner_corner' then
        intensity = intensity * 2.0
    end

    if key == 'face_adjust_upper_atrium' or key == 'face_adjust_mid_atrium' then
        intensity = -1.3 * intensity
    end

    if key == 'face_adjust_lower_atrium' then
        intensity = -intensity
    end

    return intensity
end

function FaceReshapeControlSystem:onUpdate(sys,deltaTime)
    -- get face info by size order
    self:updateFaceInfoBySize()
    -- init tempIntensity
    local tempIntensity = {}
    for tagName, entityName in pairs(nameMap) do
        tempIntensity[entityName] = {}
        for i = 0, self.maxFaceNum-1 do
            tempIntensity[entityName][i] = 0.0
        end
    end

    -- update face with valid track id
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index

        if id ~= -1 and i <= self.maxDisplayNum then
            for adjustName, entityName in pairs(nameMap) do
                local adjustIntensity = self:getValue(id, adjustName, 0.0)
                if(entityName ~= nil) then
                    -- control order
                    if(self.renderOrderDict[entityName] == nil) then
                        self.renderOrderDict[entityName] = self.tmpOrder
                        if self.entities[entityName..'_Neg_entity'] ~= nil then 
                            local renderer = self.entities[entityName..'_Neg_entity']:getComponent("MeshRenderer")
                            renderer.sortingOrder = self.tmpOrder
                        end
                        if self.entities[entityName..'_Pos_entity'] ~= nil then 
                            local renderer = self.entities[entityName..'_Pos_entity']:getComponent("MeshRenderer")
                            renderer.sortingOrder = self.tmpOrder
                        end
                        self.tmpOrder = self.tmpOrder + 1
                    end
                    tempIntensity[entityName][index] = adjustIntensity
                end
            end
        end
    end
    for tagName, entityName in pairs(nameMap) do
        local entity = self.entities[entityName..'_Pos_entity']
        local comp = entity:getComponent("FaceReshapeLiquefy")
        local renderer = entity:getComponent("MeshRenderer")
        if renderer.mesh ~= nil and renderer.mesh.submeshes ~= nil then
            renderer.mesh.submeshes:clear()
        end
        local faceNum = 0
        local faceids = {}
        local intensityParams = {}
        for faceid=0, self.maxFaceNum-1 do
            local intensity = tempIntensity[entityName][faceid]
            if intensity > EPSC then
                faceids[faceNum] = faceid
                intensityParams[faceNum] = intensity
                faceNum = faceNum + 1
            end
        end
        if faceNum==0 then
            entity.visible = false
        else
            entity.visible = true
            comp.intensityParams:resize(faceNum)
            comp.faceids:resize(self.maxFaceNum)
            for i=0, faceNum-1 do
                comp.faceids:set(i, faceids[i])
                comp.intensityParams:set(i, intensityParams[i])
            end
            for i=faceNum, self.maxFaceNum-1 do
                comp.faceids:set(i, self.maxFaceNum)
            end
        end

        local entity = self.entities[entityName..'_Neg_entity']
        local comp = entity:getComponent("FaceReshapeLiquefy")
        local renderer = entity:getComponent("MeshRenderer")
        if renderer.mesh ~= nil and renderer.mesh.submeshes ~= nil then
            renderer.mesh.submeshes:clear()
        end
        local faceNum = 0
        local faceids = {}
        local intensityParams = {}
        for faceid=0, self.maxFaceNum-1 do
            local intensity = tempIntensity[entityName][faceid]
            if intensity < -EPSC then
                faceids[faceNum] = faceid
                intensityParams[faceNum] = intensity
                faceNum = faceNum + 1
            end
        end
        if faceNum==0 then
            entity.visible = false
        else
            entity.visible = true
            comp.intensityParams:resize(faceNum)
            comp.faceids:resize(self.maxFaceNum)
            for i=0, faceNum-1 do
                comp.faceids:set(i, faceids[i])
                comp.intensityParams:set(i, intensityParams[i])
            end
            for i=faceNum, self.maxFaceNum-1 do
                comp.faceids:set(i, self.maxFaceNum)
            end
        end
    end
end

function FaceReshapeControlSystem:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function FaceReshapeControlSystem:handleIntensityEvent(comp, event)
    local key = event.args:get(0)
    for tagName, entityName in pairs(nameMap) do
        if key == tagName then
            self.faceAdjustMaps[key] = event.args:get(1)
        end
    end
end

function FaceReshapeControlSystem:updateFaceInfoBySize()
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


function FaceReshapeControlSystem:getFaceAngle(info)
    local vector = Amaz.FloatVector()
    vector:pushBack(info.yaw)
    vector:pushBack(info.pitch)
    vector:pushBack(info.roll)
    return vector
end

function FaceReshapeControlSystem:getFaceBBox(rect, mesh, offset)
    local min_x = rect.x * 2 - 1 -- left
    local min_y = rect.y * 2 - 1 -- bottom
    local max_x = (rect.x + rect.width) * 2 - 1 -- right
    local max_y = (rect.y + rect.height) * 2 - 1 -- top
    if mesh~=nil and mesh:getVertexCount() ~= 0 then
        local point0_indexs = { 113, 113, 49, 0, 32, 5, 27, 12, 20, 16 }
        local point1_indexs = { 106, 112, 43, 106, 112, 107, 111, 108, 110, 109 }
        local lerp_ratios = { 0.5, 0.5, 3, 0.5, 0.5, 0.35, 0.35, 0.2, 0.2, 0.2 }
        local point0, point1, vertex, x, y
        for i = 1, 10 do
            point0 = mesh:getVertex(point0_indexs[i] + offset)
            point1 = mesh:getVertex(point1_indexs[i] + offset)
            vertex = point0:lerp(point1, lerp_ratios[i])
            x = vertex.x * 2 / self.inputWidth - 1
            y = 1 - vertex.y * 2 / self.inputHeight
            min_x = math.min(min_x, x)
            min_y = math.min(min_y, y)
            max_x = math.max(max_x, x)
            max_y = math.max(max_y, y)
        end
    end

    local vector = Amaz.FloatVector()
    vector:pushBack(math.max(min_x, -1)) -- left
    vector:pushBack(math.min(max_y, 1)) -- top
    vector:pushBack(math.min(max_x, 1)) -- right
    vector:pushBack(math.max(min_y, -1)) -- bottom
    return vector
end


function FaceReshapeControlSystem:onLateUpdate__(comp, deltaTime)
    -- update face algo params
    local FACE_ID = "id"
    local FACE_INDEX = "index"
    local FACE_BBOX = "bbox"
    local FACE_DIRECT = "direct"
    local FACE_INFO = "face_info"
    local FACE_COUNT_EXCEED_MAX = "face_count_exceed_max"
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceAlgoParams = Amaz.Vector()
    local faceCountExceedMax = false
    for i = 1, self.maxDisplayNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index
        if id ~= -1 then
            local baseInfo = result:getFaceBaseInfo(index)
            local algoMap = Amaz.Map()
            algoMap:set(FACE_ID, id)
            algoMap:set(FACE_INDEX, index)
            algoMap:set(FACE_DIRECT, self:getFaceAngle(baseInfo))
            algoMap:set(FACE_BBOX, self:getFaceBBox(baseInfo.rect, nil, index * 248))
            faceAlgoParams:pushBack(algoMap)
        end
    end
    local freidCount = result:getFreidInfoCount()
    if freidCount > self.maxDisplayNum then
        faceCountExceedMax = true
    end

    self.scriptProps = comp.properties
    self.scriptProps:set(FACE_INFO, faceAlgoParams)
    self.scriptProps:set(FACE_COUNT_EXCEED_MAX, faceCountExceedMax)
end


exports.FaceReshapeControlSystem = FaceReshapeControlSystem
return exports
