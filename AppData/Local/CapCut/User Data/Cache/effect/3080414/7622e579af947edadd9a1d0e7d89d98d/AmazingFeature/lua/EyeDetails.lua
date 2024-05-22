      
local exports = exports or {}
local EyeDetails = EyeDetails or {}
EyeDetails.__index = EyeDetails

------------------------------------------------------------------
-- Tool function
function printAmazing(...)
    local arg = { ... }
    local msg = "mjd amazinglua: "
    for k, v in pairs(arg) do
        msg = msg .. tostring(v) .. " "
    end
    -- Amaz.LOGS("mjd", msg)
end

function makeTableStr(arg)
    local msg = ""
    if type(arg) == "table" then
        for k, v in pairs(arg) do
            if type(v) == "table" then
                local tmp =  makeTableStr(v)
                msg = msg .. tostring(k) .. ":{" .. tmp .. "},"
            else
                msg = msg .. tostring(k) .. "=" .. tostring(v) .. ","
            end
        end
    end
    return msg
end

function printAmazingTable(arg)
    if type(arg) == "table" then
        local msg = makeTableStr(arg)
        -- printAmazing(msg) 
    else
        -- printAmazing(arg)
    end
end

function table_leng(t)
    local leng=0
    for k, v in pairs(t) do
      leng=leng+1
    end
    return leng
end

------------------------------------------------------------------
local FACE_ID = "id"
local INTENSITY_TAG = "intensity"

local Item_Pouch = "face_adjust_Pouch"
local Item_NasolabialFolds = "face_adjust_NasolabialFolds"

local EPSC = 0.001

function EyeDetails.new(construct, ...)
    local self = setmetatable({}, EyeDetails)
    self.comps = {}
    self.compsdirty = true

    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.faceAdjustMaps = {}
    self.faceInfoBySize = {}
    self.intensityKeys = {
        Item_Pouch,
        Item_NasolabialFolds
    }

    self.commandBufStatic = Amaz.CommandBuffer()
    self.commandBufDynamic = Amaz.CommandBuffer()

    self.blitMaterial = nil
    self.blur1Material = nil
    self.blur1MaterialBlockMap = {}
    for i = 0, self.maxDisplayNum-1 do
        self.blur1MaterialBlockMap[i] = Amaz.MaterialPropertyBlock()
    end
    self.blur2Material = nil
    self.blur2MaterialBlockMap = {}
    for i = 0, self.maxDisplayNum-1 do
        self.blur2MaterialBlockMap[i] = Amaz.MaterialPropertyBlock()
    end
    self.eyeDetailMaterial = nil
    self.eyeDetailMaterialBlockMap = {}
    for i = 0, self.maxDisplayNum-1 do
        self.eyeDetailMaterialBlockMap[i] = Amaz.MaterialPropertyBlock()
    end
    self.makeupMeshMap = {}

    self.scaleRT = nil
    self.blur1RT = nil
    self.blur2RT = nil
    self.eyeDetailRT = nil
    self.segRTMap = {}
    for i = 0, self.maxDisplayNum-1 do
        self.segRTMap[i] = nil
    end

    self.ratio = 0.5

    self.width = 720
    self.height = 1280
    self.mvpMatrix = Amaz.Matrix4x4f()
    self.identityMatrix = Amaz.Matrix4x4f()
    self.segMatrix = Amaz.Matrix4x4f()
    self.meshUpdateTool = nil
    self.meshType = Amaz.AMGBeautyMeshType.FACE145
    self.eyeDetailIntensity = 0.0
    self.removePouchIntensity = 0.0
    self.removeNasolabialFoldsIntensity = 0.0

    self.seg = true

    return self
end

function EyeDetails:constructor()
    -- printAmazing("EyeDetails constructor")
end

function EyeDetails:onComponentAdded(sys, comp)
    -- printAmazing("EyeDetails onComponentAdded")
    if comp:isInstanceOf("TableComponent") and comp.type == "resource" then
        self.commandTableResources = comp
    end
end

function EyeDetails:onComponentRemoved(sys, comp)
    -- printAmazing("EyeDetails onComponentRemoved")
    if comp:isInstanceOf("TableComponent") and comp.type == "resource" then
        self.commandTableResources = nil
    end
end

function EyeDetails:onStart(sys)
    -- printAmazing("EyeDetails onStart")

    -- initialize
    self:initialize(sys)

    self:updateSize(sys)

    -- scale -- pass 1
    self.blitMaterial = self:createBlitMaterial()

    -- disable depth rt
    local output_rt = sys.scene:getOutputRenderTexture()
    output_rt.attachment = Amaz.RenderTextureAttachment.NONE
end

function EyeDetails:onUpdate(sys, deltaTime)
    -- handle input size change case
    local width = sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0).width
    local height = sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0).height

    if (width ~= self.width or height ~= self.height) then
        -- printAmazing("EyeDetails onUpdate() resolution changed. width=", width, "height=", height)
        self.width = width
        self.height = height

        self:updateSize(sys)
    end

    -- static command
    self.commandBufStatic:clearAll()
    self.commandBufStatic:blitWithMaterial(sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0), self.scaleRT, self.blitMaterial)
    
    -- dynamic conmmand
    self.commandBufDynamic:clearAll()
    self.commandBufDynamic:setRenderTexture(self.eyeDetailRT)
    self.commandBufDynamic:blit(sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0), self.eyeDetailRT)

    -- get face info by size order
    self:updateFaceInfoBySize()

    -- draw every face submesh
    local isZero = true
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local seat = 0
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index

        local intensityPouch = 0
        local intensityNasolabialFolds = 0

        -- check trackid, if id ~= -1, use event value
        if id ~= -1 and i <= self.maxDisplayNum then
            intensityPouch = self:getValue(id, Item_Pouch, 0) * 0.8
            intensityNasolabialFolds = self:getValue(id, Item_NasolabialFolds, 0) * 0.8
        end

        -- check faceMax count, then reset intensity 0
        if index > result:getFaceCount()-1 then
            intensityPouch = 0.0
            intensityNasolabialFolds = 0.0
        end

        if math.abs(intensityPouch) > EPSC or math.abs(intensityNasolabialFolds) > EPSC then
            -- printAmazing("update i=", i, "id=", id, "index=", index, "intensityPouch=", intensityPouch, "intensityNasolabialFolds=", intensityNasolabialFolds, "seat=", seat)
            isZero = false

            local faceMask = nil
            faceMask = result:getFaceFaceMask(index)
            self:updateSegMask(sys, seat, faceMask)

            -- blur vertically -- pass 2
            self:updateBlurMaterialBlock1(sys, seat)
            self.commandBufDynamic:setRenderTexture(self.blur1RT)
            self.commandBufDynamic:blitWithMaterialAndProperties(sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0), self.blur1RT, self.blur1Material, 0, self.blur1MaterialBlockMap[seat])

            -- blur horizontally -- pass 3
            self:updateBlurMaterialBlock2(sys, seat)
            self.commandBufDynamic:setRenderTexture(self.blur2RT)
            self.commandBufDynamic:blitWithMaterialAndProperties(self.blur1RT, self.blur2RT, self.blur2Material, 0, self.blur2MaterialBlockMap[seat])

            -- eyedetail pass 4
            self:updateEyeDetailMaterialBlock(sys, seat, intensityPouch, intensityNasolabialFolds)
            local face106Points = result:getFaceBaseInfo(index).points_array
            self.meshUpdateTool:setMesh(self.makeupMeshMap[seat], self.meshType)
            self.meshUpdateTool:updateMeshWithFaceData106(self.meshType, face106Points, 0)
            self.commandBufDynamic:setRenderTexture(self.eyeDetailRT)
            self.commandBufDynamic:drawMesh(self.makeupMeshMap[seat], self.identityMatrix, self.eyeDetailMaterial, 0, 0, self.eyeDetailMaterialBlockMap[seat])
            seat = seat + 1
        end
    end

    -- handle the case when intensity is zero 
    if isZero == false then
        sys.scene:commitCommandBuffer(self.commandBufStatic)
        sys.scene:commitCommandBuffer(self.commandBufDynamic)
    else
        -- case 3: smooth and sharp is 0, simply blit
        self.commandBufDynamic:clearAll()
        self.commandBufDynamic:setRenderTexture(self.eyeDetailRT)
        self.commandBufDynamic:blit(sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0), self.eyeDetailRT)
        sys.scene:commitCommandBuffer(self.commandBufDynamic)
    end
end

function EyeDetails:initialize(sys)
    -- mesh and AMGFaceMeshUtils object (will be used to update mesh vertices)
    for i = 0, self.maxDisplayNum-1 do
        self.makeupMeshMap[i] = self.commandTableResources.table:get("makeup_facemesh_"..i)
    end

    self.meshUpdateTool = Amaz.AMGFaceMeshUtils()

    -- material
    self.blur1Material = self.commandTableResources.table:get("blur1_material")
    self.blur2Material = self.commandTableResources.table:get("blur2_material")
    self.eyeDetailMaterial = self.commandTableResources.table:get("eyeDetail_material")

    -- render target
    self.scaleRT = self.commandTableResources.table:get("scale_rt")
    self.blur1RT = self.commandTableResources.table:get("blur1_rt")
    self.blur2RT = self.commandTableResources.table:get("blur2_rt")
    self.eyeDetailRT = self.commandTableResources.table:get("output_rt")  --output
end

function EyeDetails:updateSize(sys)
    -- rt
    local rtSize = Amaz.Vector2f(self.width * self.ratio, self.height * self.ratio)
    self.scaleRT.width = rtSize.x
    self.scaleRT.height = rtSize.y
    self.blur1RT.width = rtSize.x
    self.blur1RT.height = rtSize.y
    self.blur2RT.width = rtSize.x
    self.blur2RT.height = rtSize.y
    self.eyeDetailRT.width = self.width
    self.eyeDetailRT.height = self.height

    -- model matrix && mvp matrix
    self.identityMatrix:setIdentity()
    self.mvpMatrix:setTranslate(Amaz.Vector3f(-1, -1, 0))
    self.mvpMatrix:scale(Amaz.Vector3f(2, 2, 1))
    self.mvpMatrix:translate(Amaz.Vector3f(0, 1, 0))
    self.mvpMatrix:scale(Amaz.Vector3f(1, -1, 1))
    self.mvpMatrix:scale(Amaz.Vector3f(1.0 / self.width, 1.0 / self.height, 1))

    -- printAmazing("updateRt, width=", rtSize.x, "height=", rtSize.y, "HeightOffset=", 1.0 / rtSize.y, "WidthOffset=", 1.0 / rtSize.x)
end

function EyeDetails:updateSegMask(sys, seat, faceMask)
    if self.seg == true and faceMask ~= nil then
        local warp_mat = faceMask.warp_mat
        local W = faceMask.face_mask_size
        local H = faceMask.face_mask_size
        self.segMatrix:SetRow(0, Amaz.Vector4f(warp_mat:get(0) / W, warp_mat:get(1) / W, 0.0, warp_mat:get(2) / W))
        self.segMatrix:SetRow(1, Amaz.Vector4f(warp_mat:get(3) / H, warp_mat:get(4) / H, 0.0, warp_mat:get(5) / H))
        self.segMatrix:SetRow(2, Amaz.Vector4f(0.0, 0.0, 1.0, 0.0))
        self.segMatrix:SetRow(3, Amaz.Vector4f(0.0, 0.0, 0.0, 1.0))

        if self.segRTMap[seat] == nil then
            self.segRTMap[seat] = Amaz.Texture2D()
            self.segRTMap[seat].filterMin = Amaz.FilterMode.LINEAR
            self.segRTMap[seat].filterMag = Amaz.FilterMode.LINEAR
        end
        self.segRTMap[seat]:storage(faceMask.image)
    end
end

function EyeDetails:updateBlurMaterialBlock1(sys, seat)
    local rtSize = Amaz.Vector2f(self.width * self.ratio, self.height * self.ratio)

    self.blur1MaterialBlockMap[seat]:setFloat("texelHeightOffset", 1.0 / rtSize.y * self.height / 1280 * 0.6)
    -- self.blur1MaterialBlockMap[seat]:setFloat("texelHeightOffset", 1.0 / rtSize.y)
    self.blur1MaterialBlockMap[seat]:setFloat("texelWidthOffset", 0.0)

    if self.seg == true then
        local vec2s = Amaz.Vec2Vector()
        vec2s:pushBack(Amaz.Vector2f(self.width, self.height))

        self.blur1MaterialBlockMap[seat]:setFloat("scaleOffset", 3.0)
        self.blur1MaterialBlockMap[seat]:setMatrix("uSegMatrix", self.segMatrix)
        self.blur1MaterialBlockMap[seat]:setVec2Vector("inputSize", vec2s)
        self.blur1MaterialBlockMap[seat]:setTexture("segMaskTexture", self.segRTMap[seat])
    end
end

function EyeDetails:updateBlurMaterialBlock2(sys, seat)
    local rtSize = Amaz.Vector2f(self.width * self.ratio, self.height * self.ratio)
    self.blur2MaterialBlockMap[seat]:setFloat("texelHeightOffset", 0.0)
    self.blur2MaterialBlockMap[seat]:setFloat("texelWidthOffset", 1.0 / rtSize.x * self.width / 720 * 0.6)
    -- self.blur2MaterialBlockMap[seat]:setFloat("texelWidthOffset", 1.0 / rtSize.x)

    if self.seg == true then
        local vec2s = Amaz.Vec2Vector()
        vec2s:pushBack(Amaz.Vector2f(self.width, self.height))

        self.blur2MaterialBlockMap[seat]:setFloat("scaleOffset", 3.0)
        self.blur2MaterialBlockMap[seat]:setMatrix("uSegMatrix", self.segMatrix)
        self.blur2MaterialBlockMap[seat]:setVec2Vector("inputSize", vec2s)
        self.blur2MaterialBlockMap[seat]:setTexture("segMaskTexture", self.segRTMap[seat])
    end
end

function EyeDetails:updateEyeDetailMaterialBlock(sys, seat, intensityPouch, intensityNasolabialFolds)
    self.eyeDetailMaterialBlockMap[seat]:setMatrix("uMVPMatrix", self.mvpMatrix)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("texelWidthOffset", 1.0 / self.width * self.width / 720 * 0.6)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("texelHeightOffset", 1.0 / self.height * self.height / 1280 * 0.6)
    -- self.eyeDetailMaterialBlockMap[seat]:setFloat("texelWidthOffset", 1.0 / self.width)
    -- self.eyeDetailMaterialBlockMap[seat]:setFloat("texelHeightOffset", 1.0 / self.height)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("intensity", 1.0)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("eyeDetailIntensity", self.eyeDetailIntensity)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("removePouchIntensity", intensityPouch)
    self.eyeDetailMaterialBlockMap[seat]:setFloat("removeNasolabialFoldsIntensity", intensityNasolabialFolds)
    self.eyeDetailMaterialBlockMap[seat]:setTexture("inputImageTexture", sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0))
    self.eyeDetailMaterialBlockMap[seat]:setTexture("inputScaledTexture", self.scaleRT)
    self.eyeDetailMaterialBlockMap[seat]:setTexture("inputScaledBlurTexture", self.blur2RT)
    local vec2s = Amaz.Vec2Vector()
    vec2s:pushBack(Amaz.Vector2f(self.width, self.height))
    self.eyeDetailMaterialBlockMap[seat]:setVec2Vector("inputSize", vec2s)

    if self.seg == true then
        self.eyeDetailMaterialBlockMap[seat]:setMatrix("uSegMatrix", self.segMatrix)
        self.eyeDetailMaterialBlockMap[seat]:setTexture("segMaskTexture", self.segRTMap[seat])
    end
end

function EyeDetails:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(sys, event)
    end
end

function EyeDetails:hitKey(key)
    for i = 1, #self.intensityKeys do
        if key == self.intensityKeys[i] then
            return true
        end
    end
    return false
end

function EyeDetails:handleIntensityEvent(sys, event)
    local key = event.args:get(0)
    -- printAmazing("event key=", key)
    if self:hitKey(key) then
        self.faceAdjustMaps[key] = event.args:get(1)

        -- local vec = self.faceAdjustMaps[key]
        -- local inputSize = vec:size()
        -- for i = 0, inputSize-1 do
        --     local inputMap = vec:get(i)
        --     local keys = inputMap:getVectorKeys()
        --     for j = 0, keys:size()-1 do
        --         -- printAmazing("event index=", j, "key=", keys:get(j), "value", inputMap:get(keys:get(j)))
        --     end            
        -- end
    end
end

function EyeDetails:getValue(id, key, default)
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

function EyeDetails:updateFaceInfoBySize()
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

    -- printAmazing("faceInfoSize=", makeTableStr(self.faceInfoBySize))
end

function EyeDetails:createBlitMaterial()
    local blitMaterial = Amaz.Material()
    local blitXShader = Amaz.XShader()
    local blitPass = Amaz.Pass()
    local vs = Amaz.Shader()
    vs.type = Amaz.ShaderType.VERTEX
    vs.source =
        [[
        precision highp float;
        attribute vec3 attrPos;
        attribute vec2 attrUV;
        varying vec2 uv;
        void main() {
            gl_Position = vec4(attrPos, 1.0);
            uv = attrUV;
        }
    ]]
    local fs = Amaz.Shader()
    fs.type = Amaz.ShaderType.FRAGMENT
    fs.source =
        [[
        precision highp float;
        uniform sampler2D _MainTex;
        varying vec2 uv;

        void main() {
            vec4 color = texture2D(_MainTex, uv);
            gl_FragColor = color;
        }
    ]]
    local shaders = Amaz.Map()
    local shaderList = Amaz.Vector()
    shaderList:pushBack(vs)
    shaderList:pushBack(fs)
    shaders:insert("gles2", shaderList)
    blitPass.shaders = shaders
    local seman = Amaz.Map()
    seman:insert("attrPos", Amaz.VertexAttribType.POSITION)
    seman:insert("attrUV", Amaz.VertexAttribType.TEXCOORD0)
    blitPass.semantics = seman

    -- render state
    local renderState = Amaz.RenderState()
    --depth state
    local depthStencilState = Amaz.DepthStencilState()
    depthStencilState.depthTestEnable = false
    renderState.depthstencil = depthStencilState
    blitPass.renderState = renderState
    blitXShader.passes:pushBack(blitPass)
    blitMaterial.xshader = blitXShader
    return blitMaterial
end

function EyeDetails:createRT(width, height)
    local rt = Amaz.RenderTexture()
    rt.width = width
    rt.height = height
    rt.depth = 1
    rt.filterMag = Amaz.FilterMode.LINEAR
    rt.filterMin = Amaz.FilterMode.LINEAR
    rt.filterMipmap = Amaz.FilterMipmapMode.NONE
    rt.attachment = Amaz.RenderTextureAttachment.NONE
    return rt
end

function createScreenMesh()
    -- create Mesh
    local mesh = Amaz.Mesh()
    local pos = Amaz.VertexAttribDesc()
    pos.semantic = Amaz.VertexAttribType.POSITION
    local uv = Amaz.VertexAttribDesc()
    uv.semantic = Amaz.VertexAttribType.TEXCOORD0
    local vads = Amaz.Vector()
    vads:pushBack(pos)
    vads:pushBack(uv)
    mesh.vertexAttribs = vads
    local vertexData = {
        -1.0, -1.0, 0.0, 0.0, 0.0,
         3.0, -1.0, 0.0, 2.0, 0.0,
        -1.0,  3.0, 0.0, 0.0, 2.0,
    }
    local fv = Amaz.FloatVector()
    for i = 1, table.getn(vertexData) do
        fv:pushBack(vertexData[i])
    end
    mesh.vertices = fv

    -- create SubMesh
    subMesh = Amaz.SubMesh()
    subMesh.primitive = Amaz.Primitive.TRIANGLES
    local indices = Amaz.UInt16Vector()
    indices:pushBack(0)
    indices:pushBack(1)
    indices:pushBack(2)
    subMesh.indices16 = indices
    subMesh.mesh = mesh
    mesh:addSubMesh(subMesh)
    return mesh
end

exports.EyeDetails = EyeDetails
return exports

    