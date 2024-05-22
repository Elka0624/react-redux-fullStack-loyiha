local exports = exports or {}
local TextAnim = TextAnim or {}
---@class TextAnim : ScriptComponent
---@field isRenderToRT boolean
---@field autoPlay boolean
---@field MaskOffset number [UI(Range={-1.5, 1.6}, Slider)]
---@field progress number [UI(Range={0.0, 2.0}, Slider)]
---@field effectMaterial Material
TextAnim.__index = TextAnim

function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)
    self.isRenderToRT = false
    self.MaskOffset = -1.0
    self.MaskXOffset = -0.5
    self.progress = 0.0
    self.curTime = 0.0
    self.autoPlay = false
    self.duration = 1.0
    self.width = 100
    self.height = 100
    self.effectMaterial = nil
    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()
    self.name = "scriptComp"
end

function TextAnim:setMatToSDFText()
    local materials = Amaz.Vector()
    local InsMaterials = nil
    if self.effectMaterial then
        InsMaterials = self.effectMaterial:instantiate()
    else
        InsMaterials = self.renderer.material
    end
    materials:pushBack(InsMaterials)
    self.materials = materials
    self.renderer.materials = self.materials

    self.textMat = self.renderer.material
end

function TextAnim:onStart(comp)
    self.textMat = nil
    self.text = comp.entity:getComponent("SDFText")
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
            self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end 
    self.renderer = nil
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end

    self.trans = comp.entity:getComponent("Transform")
    self.first = true
end

function TextAnim:onUpdate(comp, deltaTime)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        self.curTime = deltaTime + self.curTime 
        self:seek(self.curTime)
    end
end
local clamp = function(min, max, value)
	return math.min(math.max(value, min), max)
end

function TextAnim:seek(time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        if self.autoPlay then
            self.progress = time % self.duration / self.duration
            -- self.progress = time / self.duration
        end
    else
        -- self.progress = clamp(0.0, 1.0, time / self.duration)
        self.progress = time / self.duration

    end
    if self.first == true then
        self.text.renderToRT = true
        if self.text.renderToRT == true then
            self:setMatToSDFText()
        end
        self.text.targetRTExtraSize = Amaz.Vector2f(self.text.rect.width, 0.0)
        self.width = self.text.rect.width
        self.height = self.text.rect.height
        self.first = false
    end
    -- local rt = self.textMat:getTex("_MainTex")
    -- if rt then
    --     self.textMat:setVec2("u_TextRect", Amaz.Vector2f(rt.width, rt.height))
    -- end
    self.textMat:setVec2("u_TextRect", Amaz.Vector2f(self.width * 2, self.height))

    -- self.textMat:setFloat("u_Offset", self.MaskOffset)
    -- self.textMat:setFloat("u_XOffset", self.MaskXOffset)
    local frame = 7.0 * math.max(math.min(self.duration, 2.0), 1.0)
    local progress1 = math.floor(self.progress * 14) / (14)
    progress1 = math.pow(progress1, 0.4)


    local frame1 = 7.0 * math.max(math.min(self.duration, 2.0), 1.0)
    local progress2 = math.floor(self.progress * frame1) / (frame1)
    progress2 = math.pow(progress2, 0.4)
    self.textMat:setFloat("u_Progress", progress1)
    self.textMat:setFloat("u_Progress1", progress2)
    -- self.quadMat:setFloat("u_Progress", self.progress)
    -- if self.autoPlay == true then
    --     self.curTime = deltaTime * 0.5 + self.curTime
    --     self.progress = self.curTime % 1.0
    -- end
end
function TextAnim:onEnter()
	self.first = true
	
end
function TextAnim:resetData( ... )
	if self.text ~= nil then
    	local chars = self.text.chars 
		for i = 1, self.text.chars:size() do
			local char = chars:get(i - 1)
			if char.rowth ~= -1 then
				char.position = char.initialPosition
				char.rotate = Amaz.Vector3f(0, 0, 0)
				char.scale = Amaz.Vector3f(1, 1, 1)
				char.color = Amaz.Vector4f(1, 1, 1, 1)
			end
		end
		self.text.chars = chars
	end

	self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
	self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
	self.trans.localScale = Amaz.Vector3f(1, 1, 1)
    self.text.targetRTExtraSize = Amaz.Vector2f(0.0, 0.0)
end

function TextAnim:setDuration(duration)
   self.duration = duration
end
function TextAnim:onLeave()
	self:resetData()
	self.text.renderToRT = false
	self.first = true
end
function TextAnim:clear()
	self:resetData()
	self.text.renderToRT = false
end

exports.TextAnim = TextAnim
return exports
