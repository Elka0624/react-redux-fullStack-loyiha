local exports = exports or {}
local SmoothV7Plus = SmoothV7Plus or {}
SmoothV7Plus.__index = SmoothV7Plus

-- output
local FACE_ADJUST = "face_adjust"
local FACE_ADJUST_INTENSITY = "intensity"

-- runtime
local MIN = math.min
local MAX = math.max
local MOD = math.modf
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG SmoothV7Plus.lua"

function SmoothV7Plus.new(construct, ...)
    local self = setmetatable({}, SmoothV7Plus)
    self.comps = {}
    self.compsdirty = true

    self.inputTex = nil

    self.commandBufDynamic = Amaz.CommandBuffer()
    self.commandBufStatic = Amaz.CommandBuffer() 

    self.makeupMaterial = nil
    self.makeupMaterialBlock = Amaz.MaterialPropertyBlock()
    self.box1Material = nil
    self.varMaterial = nil
    self.varMaterialBlock = Amaz.MaterialPropertyBlock()
    self.box2Material = nil
    self.box3Material = nil
    self.smoothMaterial = nil
    self.smoothMaterialBlock = Amaz.MaterialPropertyBlock()

    self.makeupRT = nil
    self.box1RT = nil
    self.varRT = nil
    self.smoothRT = nil

    self.width = 720
    self.height = 1280

    self.meshUpdateTool = nil
    self.makeupMesh = nil
    self.meshType = Amaz.AMGBeautyMeshType.FACE145
    self.submeshIndicesCount = 768

    self.identityMatrix = Amaz.Matrix4x4f()

    self.smoothIntensity = 0.0
    self.sharpIntensity = 0.0
    self.eyeDetailIntensity = 0.0
    self.removePouchIntensity = 0.0
    self.removeNasolabialFoldsIntensity = 0.0
    self.exclusiveFlag = false

    self.isFrontCamera = true

    return self
end

function SmoothV7Plus:initialize(scene)
    
    local commandTableResources = scene:findEntityBy("SmoothV7Plus"):getComponent("TableComponent")

    -- mesh and AMGFaceMeshUtils object (will be used to update mesh vertices)
    self.makeupMesh = commandTableResources.table:get("makeup_facemesh") 
    if self.makeupMesh ~= nil then
        self.meshUpdateTool = Amaz.AMGFaceMeshUtils()
        self.meshUpdateTool:setMesh(self.makeupMesh, self.meshType)
    end

    -- INPUT0
    self.inputTex = commandTableResources.table:get("input_texture")

    -- camera input width and height
    self.width = self.inputTex.width
    self.height = self.inputTex.height

    self.makeupMaterial = commandTableResources.table:get("makeup_material")
    self.box1Material = commandTableResources.table:get("box1_material")
    self.varMaterial = commandTableResources.table:get("var_material")
    self.box2Material = commandTableResources.table:get("box2_material")
    self.box3Material = commandTableResources.table:get("box3_material")
    self.smoothMaterial = commandTableResources.table:get("smooth_material")


    -- render target
    self.makeupRT = commandTableResources.table:get("makeup_rt")
    self.box1RT = commandTableResources.table:get("box1_rt")
    self.varRT = commandTableResources.table:get("var_rt")
    self.smoothRT = commandTableResources.table:get("smooth_rt")   --output
    self.skinsegTex = Amaz.Texture2D()
    self.smoothMaterial:setTex("skinMask", self.skinsegTex)


    -- model matrix and mvp matrix
    self.identityMatrix:SetIdentity()

    local mvpMatrix = Amaz.Matrix4x4f()
    mvpMatrix:SetTranslate(Amaz.Vector3f(-1, -1, 0))
    mvpMatrix:Scale(Amaz.Vector3f(2, 2, 1))
    mvpMatrix:Translate(Amaz.Vector3f(0, 1, 0))
    mvpMatrix:Scale(Amaz.Vector3f(1, -1, 1))
    mvpMatrix:Scale(Amaz.Vector3f(1.0 / self.width, 1.0 / self.height, 1))
    self.makeupMaterialBlock:setMatrix("uMVPMatrix", mvpMatrix)

    -- disable depth rt
    local outputRT = scene:getOutputRenderTexture()
    outputRT.attachment = Amaz.RenderTextureAttachment.NONE

    -- clear irrelevant events
    local scriptSys = scene:getSystem("ScriptSystem")
    scriptSys:clearAllEventType()
    scriptSys:addEventType(Amaz.AppEventType.SetEffectIntensity)

    -- -- set sharp intensity
    -- local platformName = Amaz.Platform.name()
    -- if platformName == "iOS" then
    --     self.sharpIntensity = 0.7
    -- elseif platformName == "Android" then
    --     self.sharpIntensity = 0.05
    -- else
    --     self.sharpIntensity = 0.0   -- TBD
    -- end

    -- get camera's default position
    if Amaz.Input:getCameraPosition() == 0 then
        self.isFrontCamera = true
    else
        self.isFrontCamera = false
    end    
end

function SmoothV7Plus:onStart(comp, script)

    local scene = script.scene
    self.scriptProps = comp.properties
    local segmentId = self.scriptProps:get(SEGMENT_ID)
    if segmentId ~= nil then
        self.logTag = string.format('%s %s', LOG_TAG, segmentId)
    else
        self.logTag = LOG_TAG
    end

    self:initialize(scene)

    --makeup -- pass 1
    self.commandBufStatic:setRenderTexture(self.makeupRT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.commandBufStatic:drawMesh(self.makeupMesh, self.identityMatrix, self.makeupMaterial, 0, 0, self.makeupMaterialBlock, true)  -- batch multiple face, cache

    -- box blur x -- pass 2
    self.commandBufStatic:setRenderTexture(self.box1RT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.commandBufStatic:blitWithMaterial(self.inputTex, self.box1RT, self.box1Material, 0, true)

    -- box blur y -- pass 3
    self.commandBufStatic:setRenderTexture(self.varRT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.varMaterial:setTex("blurImageTex", self.box1RT)
    self.commandBufStatic:blitWithMaterialAndProperties(self.inputTex, self.varRT, self.varMaterial, 0, self.varMaterialBlock, true)

    -- var blur x -- pass 4
    self.commandBufStatic:setRenderTexture(self.box1RT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.commandBufStatic:blitWithMaterial(self.varRT, self.box1RT, self.box2Material, 0, true)   -- reuse box1

    -- var blur y -- pass 5 
    self.commandBufStatic:setRenderTexture(self.varRT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.commandBufStatic:blitWithMaterial(self.box1RT, self.varRT, self.box3Material, 0, true)   -- reuse box1, var

    -- smooth -- pass 6
    self.commandBufStatic:setRenderTexture(self.smoothRT)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
    self.smoothMaterial:setTex("beautyMaskTexture", self.makeupRT)
    self.smoothMaterial:setTex("blurImageTex", self.varRT) 

    self.commandBufStatic:blitWithMaterialAndProperties(self.inputTex, self.smoothRT, self.smoothMaterial, 0, self.smoothMaterialBlock, true)
end

function SmoothV7Plus:onUpdate(comp,deltaTime)
    -- handle the case when been exclusive
    if self.exclusiveFlag then
        -- case 1: been exclusived, simply blit 
        self.commandBufDynamic:clearAll()
        self.commandBufDynamic:setRenderTexture(self.smoothRT)
        self.commandBufDynamic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
        self.commandBufDynamic:blit(self.inputTex, self.smoothRT)
        comp.entity.scene:commitCommandBuffer(self.commandBufDynamic)
        return
    end

    local width = self.inputTex.width
    local height = self.inputTex.height
    if width ~= self.width or height ~= self.height then
        Amaz.LOGI("v7", "v7: onUpdate resolution changed")
        self.width = width
        self.height = height

        local mvpMatrix = Amaz.Matrix4x4f()
        mvpMatrix:SetTranslate(Amaz.Vector3f(-1, -1, 0))
        mvpMatrix:Scale(Amaz.Vector3f(2, 2, 1))
        mvpMatrix:Translate(Amaz.Vector3f(0, 1, 0))
        mvpMatrix:Scale(Amaz.Vector3f(1, -1, 1))
        mvpMatrix:Scale(Amaz.Vector3f(1.0 / self.width, 1.0 / self.height, 1))
        self.makeupMaterialBlock:setMatrix("uMVPMatrix", mvpMatrix)
    end

    local faceCount = 0
    local result =  Amaz.Algorithm:getAEAlgorithmResult()
    local segInfo = result:getSkinSegInfo()
    if result ~= nil then
        faceCount = result:getFaceCount()
    end

    -- update uniforms which needs to update
    self.smoothMaterialBlock:setFloat("texEpmWidthOffset", 1.0 / self.width)
    self.smoothMaterialBlock:setFloat("texEpmHeightOffset", 1.0 / self.height)
    self.smoothMaterialBlock:setFloat("smoothIntensity", self.smoothIntensity)
    self.smoothMaterialBlock:setFloat("sharpIntensity", self.sharpIntensity)
    self.smoothMaterialBlock:setFloat("eyeDetailIntensity", self.eyeDetailIntensity)
    self.smoothMaterialBlock:setFloat("removePouchIntensity", self.removePouchIntensity)
    self.smoothMaterialBlock:setFloat("removeLaughlineIntensity", self.removeNasolabialFoldsIntensity)

    -- front and back camera strategy
    if faceCount > 0 then
        self.smoothMaterialBlock:setFloat("useMask", 1.0)
        self.smoothMaterialBlock:setFloat("defaultMaskValue", 0.6)
    else
        self.smoothMaterialBlock:setFloat("useMask", 0.0)
        if self.isFrontCamera == true then
            self.smoothMaterialBlock:setFloat("defaultMaskValue", 0.6)
        else
            self.smoothMaterialBlock:setFloat("defaultMaskValue", 0.2)      
        end
    end

    -- update face data
    if result ~= nil then
        local count = math.min(faceCount, 5)
        for i = 0, count-1 do
            local face106Points = result:getFaceBaseInfo(i).points_array
            self.meshUpdateTool:updateMeshWithFaceData106(self.meshType, face106Points, i)
        end
        self.makeupMesh:getSubMesh(0).indicesCount = count * self.submeshIndicesCount
    end

    if segInfo ~= nil then
        local segImage = segInfo.data
        self.skinsegTex:storage(segImage)
    end

    -- handle the case when intensity is zero 
    if self.smoothIntensity > 0.0 or self.removePouchIntensity > 0.0 or self.removeNasolabialFoldsIntensity > 0.0 or self.eyeDetailIntensity > 0.0 then 
        comp.entity.scene:commitCommandBuffer(self.commandBufStatic)
    elseif self.sharpIntensity > 0.0 then
        -- case 2: smooth is 0, sharp is not 0, take pass 6
        self.commandBufDynamic:clearAll()
        self.commandBufDynamic:setRenderTexture(self.smoothRT)
        self.commandBufDynamic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
        self.commandBufDynamic:blitWithMaterialAndProperties(self.inputTex, self.smoothRT, self.smoothMaterial, 0, self.smoothMaterialBlock)
        comp.entity.scene:commitCommandBuffer(self.commandBufDynamic)
    else
        -- case 3: smooth and sharp is 0, simply blit
        self.commandBufDynamic:clearAll()
        self.commandBufDynamic:setRenderTexture(self.smoothRT)
        self.commandBufDynamic:clearRenderTexture(true, true, Amaz.Color(0.0, 0.0, 0.0, 0.0))
        self.commandBufDynamic:blit(self.inputTex, self.smoothRT)
        comp.entity.scene:commitCommandBuffer(self.commandBufDynamic)
    end
end

function SmoothV7Plus:onEvent(comp,event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event.args)
    end
end

function SmoothV7Plus:handleIntensityEvent(comp, args)
    local inputKey = args:get(0)
    local inputValue = args:get(1)
    Amaz.LOGS(self.logTag, "handleIntensityEvent set " .. inputKey)

    if inputKey == FACE_ADJUST then
        local inputSize = inputValue:size()
        if inputSize > 0 then
            local inputMap = inputValue:get(0)
            local _intensity = inputMap:get(FACE_ADJUST_INTENSITY)
            self.smoothIntensity = _intensity
            if _intensity >= 0.6 then
                self.sharpIntensity = 0.7
            else
                self.sharpIntensity = 1.1667 * _intensity
            end
        end
    end
end

exports.SmoothV7Plus = SmoothV7Plus
return exports
