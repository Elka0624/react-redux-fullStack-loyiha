local exports = exports or {}
local TextAnim = TextAnim or {}
---@class TextAnim:ScriptComponent
---@field effectMaterial Material
---@field quad Mesh
---@field alphaStart number
---@field alphaEnd number
---@field alphaOffset number
---@field duration number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field autoPlay boolean
---@field sharedMaterial Material
---@field renderToRT boolean
TextAnim.__index = TextAnim


local util = nil      ---@type Util
local isEditor = Amaz.Macros and Amaz.Macros.EditorSDK

local AETools = AETools or {}
AETools.__index = AETools

function AETools:new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    local max_frame = 0
    local min_frame = 100000
    for _,v in pairs(attrs) do
        for i = 1, #v do
            local content = v[i]
            local cur_frame_min = content[2][1]
            local cur_frame_max = content[2][2]
            max_frame = math.max(cur_frame_max, max_frame)
            min_frame = math.min(cur_frame_min, min_frame)
        end
    end

    self.all_frame = max_frame - min_frame
    self.min_frame = min_frame

    return self
end

function AETools._remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function AETools._cubicBezier(p1, p2, p3, p4, t)
    return {
        p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
        p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
    }
end

function AETools:_cubicBezier01(_bezier_val, p)
    local x = self:_getBezier01X(_bezier_val, p)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1,1},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1,1},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x)
    return a * (1-x) + b * x
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame + self.min_frame

    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress)
 
                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p)
            end

        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return first_info[3][1]
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return last_info[3][2]
    end

    return nil
end

function AETools:test()
    Amaz.LOGI("lrc "..tostring(self.key_frame_info), tostring(#self.key_frame_info))
end


local util = {}     ---@class Util
local json = cjson.new()
local rootDir = nil
local record_t = {}

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end

local function changeVec2ToTable(val)
    return {val.x, val.y}
end

local function changeVec3ToTable(val)
    return {val.x, val.y, val.z}
end

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function changeCol3ToTable(val)
    return {val.r, val.g, val.b}
end

local function changeCol4ToTable(val)
    return {val.r, val.g, val.b, val.a}
end

local function changeTable2Vec4(t)
    return Amaz.Vector4f(t[1], t[2], t[3], t[4])
end

local function changeTable2Vec3(t)
    return Amaz.Vector3f(t[1], t[2], t[3])
end

local function changeTable2Vec2(t)
    return Amaz.Vector2f(t[1], t[2])
end

local function changeTable2Col3(t)
    return Amaz.Color(t[1], t[2], t[3])
end

local function changeTable2Col4(t)
    return Amaz.Color(t[1], t[2], t[3], t[4])
end

local _typeSwitch = {
    ["vec4"] = function(v)
        return changeVec4ToTable(v)
    end,
    ["vec3"] = function(v)
        return changeVec3ToTable(v)
    end,
    ["vec2"] = function(v)
        return changeVec2ToTable(v)
    end,
    ["float"] = function(v)
        return tonumber(v)
    end,
    ["string"] = function(v)
        return tostring(v)
    end,
    ["col3"] = function(v)
        return changeCol3ToTable(v)
    end,
    ["col4"] = function(v)
        return changeCol4ToTable(v)
    end,

    -- change table to userdata
    ["_vec4"] = function(v)
        return changeTable2Vec4(v)
    end,
    ["_vec3"] = function(v)
        return changeTable2Vec3(v)
    end,
    ["_vec2"] = function(v)
        return changeTable2Vec2(v)
    end,
    ["_float"] = function(v)
        return tonumber(v)
    end,
    ["_string"] = function(v)
        return tostring(v)
    end,
    ["_col3"] = function(v)
        return changeTable2Col3(v)
    end,
    ["_col4"] = function(v)
        return changeTable2Col4(v)
    end,
}

local function typeSwitch()
    return _typeSwitch
end

local function createTableContent()
    -- Amaz.LOGI("lrc", "createTableContent")
    local t = {}
    for k,v in pairs(record_t) do
        t[k] = {}
        t[k]["type"] = v["type"]
        t[k]["val"] = v["func"](v["val"])
    end
    return t
end

function util.registerParams(_name, _data, _type)
    record_t[_name] = {
        ["type"] = _type,
        ["val"] = _data,
        ["func"] = _typeSwitch[_type]
    }
end

function util.getRegistedParams()
    return record_t
end

function util.setRegistedVal(_name, _data)
    record_t[_name]["val"] = _data
end

function util.getRootDir()
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    Amaz.LOGI("lrc getRootDir 123", tostring(rootDir))
    return rootDir
end

function util.registerRootDir(path)
    Amaz.LOGI("lrc registerRootDir", tostring(path))
    rootDir = path
end

function util.bezier(controls)
    local control = controls
    if type(control) ~= "table" then
        control = changeVec4ToTable(controls)
    end
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(control, t)
        local value =  getBezierValue(control, tvalue)
        return b + c * value[2]
    end
end

function util.remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function util.mix(a, b, x)
    return a * (1-x) + b * x
end

function util.CreateJsonFile(file_path)
    local t = createTableContent()
    local content = json.encode(t)
    local file = io.open(util.getRootDir()..file_path, "w+b")
    if file then
      file:write(tostring(content))
      io.close(file)
    end
end

function util.ReadFromJson(file_path, jsonData)
    local file = io.input(util.getRootDir() .. file_path)
    local text = io.read("*a")
    if jsonData ~= "" then
        text = jsonData
    end
    local json_data = json.decode(text)
    return json_data
end

function util.bezierWithParams(input_val_4, min_val, max_val, in_val, reverse)
    if type(input_val_4) == "tabke" then
        if reverse == nil then
            return util.bezier(input_val_4)(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(input_val_4)(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    else
        if reverse == nil then
            return util.bezier(util.changeVec4ToTable(input_val_4))(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(util.changeVec4ToTable(input_val_4))(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    end
end


function util.clamp(min, max, value)
	return math.min(math.max(value, min), max)
end

function util.test()
    Amaz.LOGI("lrc", "test123")
end

local ae_attribute = {
	["ADBE_Gaussian_Blur_2_0001_0_0"]={
		{{0.33333333, 0, 0.1, 1, }, {0, 4, }, {{40, }, {0, }, }, }, 
	}, 
	["ADBE_Scale_0_1"]={
		{{0.166666667,0.166666667,0.166666667, 0,0,0.166666667, 0.833333333,0.833333333,0.833333333, 0.833333333,0.833333333,0.833333333, }, {0, 4, }, {{0, 0, 100, }, {50, 50, 100, }, }, }, 
		{{0.166666667,0.166666667,0.166666667, 0.166666667,0.166666667,0.166666667, 0.48,0.48,0.48, 1,1,0.48, }, {4, 18, }, {{50, 50, 100, }, {100, 100, 100, }, }, }, 
	}, 
	["ADBE_Scale_1_2"]={
		{{0.03,0.03,0.03, 0,0,0.03, 0.2,0.2,0.2, 1,1,0.2, }, {5, 34, }, {{50, 50, 100, }, {100, 100, 100, }, }, }, 
	}, 
}

function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)
    self.effectMaterial = nil
    self.curTime = 0
    self.progress = 0
    self.autoPlay = false
    self.duration = 1.0
    self.quad = nil
    self.offset = 220.6380781101
    self.alphaStart = 0
    self.alphaEnd = 0.2
    self.lastTime = self.lastTime or 0.0
    self.alphaOffset = -0.15
    self.x1 = 0
    self.y1 = 0
    self.x2 = 0
    self.y2 = 0
    self.lastGap = 0.0
    self.renderToRT = true
    self.intensity = 0.5
    self.lastIntensity = 0.5
    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()
    self.name = "scriptComp"
end

local function getRootDir()
    local rootDir = nil
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    return rootDir
end

function TextAnim:onSetProperty(key, value)
    if key == "caption_duration_info" and value ~= "" then
        self:ReadFromJson(value)
        -- self:initAnim()
    end
end

function TextAnim:onStart(comp)

    util.registerRootDir(getRootDir())

    self.text = comp.entity:getComponent('SDFText')
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
            self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.rich_text = comp.entity:getComponent('Text')
    self.renderer = true
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end
    self.first = true
    self.trans = comp.entity:getComponent("Transform")
    self.parentTrans = self.trans.parent
    self.parentEntity = self.parentTrans.entity

    self:transInitial(self.trans)
    -- self.textTimeData = {}
    -- if Amaz.Macros and Amaz.Macros.EditorSDK then
    --     self:ReadFromJson("")
    -- else
    -- end
    self.first = true
    -- Amaz.LOGI("lrc onstart", self.text.outlineMaxWidth)
    self.text.outlineMaxWidth = 0.2

    self.attrs = AETools:new(ae_attribute)

    self.user_set_font_size = nil

    -- self.wordGap = self.text.wordGap
    -- self.blendMat = comp.entity.scene:findEntityBy("Blend"):getComponent("MeshRenderer").material
end

function TextAnim:ReadFromJson(jsondata)
    Amaz.LOGI("lrc readfrom json", "read from json")
    local jsonData = util.ReadFromJson("data_val.json", jsondata)
    self.textTimeData = jsonData
end

function TextAnim:transInitial(trans)
    trans.localScale = Amaz.Vector3f(1.,1.,1.)
    trans.localPosition = Amaz.Vector3f(0.,0.,0.)
    trans.localEulerAngle = Amaz.Vector3f(0.,0.,0.)
end

function TextAnim:setMatToSDFText()

    self.text.renderToRT = true
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

    self.material = self.renderer.material
end

function TextAnim:initAnimConfig()
    self.text:forceTypeSetting()
	self.count = self.text.chars:size()
    self.size = {}
    for i = 0, self.text.chars:size() - 1 do
        local char = self.text.chars:get(i)
        if char.utf8code ~= "\n" then
            self.size[char.rowth] = char.idInRow
        end
    end
end

function TextAnim:onUpdate(comp, time)
    if isEditor then
        self.curTime = self.curTime + time
        self:seek(self.curTime)
    end
end

local clamp = function(a, b, x)
    return math.max(math.min(x, b), a)
end

--
function TextAnim:getTextColor()
    local text = self.text.entity:getComponent("Text")
    local textColor = Amaz.Vector3f(1.0,1.0,1.0)
    if text then --
        if text.forceFlushCommandQueue then
            text:forceFlushCommandQueue()
        end
        local letters = text.letters
        if letters:size() > 0 then
            local letter0 = letters:get(0)
            textColor = letter0 and letter0.letterStyle and letter0.letterStyle.letterColor
        end
    else
        textColor = self.text.textColor
    end
    return textColor
end

function TextAnim:getTextFontSize()
    local text = self.rich_text
    -- local textColor = Amaz.Vector3f(1.0,1.0,1.0)
    local fontSize = 24
    if text then
        
        if text.forceFlushCommandQueue then
            text:forceFlushCommandQueue()
        end
        local letters = text.letters
        if letters:size() > 0 then
            local letter0 = letters:get(0)
            fontSize = letter0 and letter0.letterStyle and letter0.letterStyle.fontSize
        end
    else
        fontSize = self.text.fontSize
    end
    return fontSize
end

local function GetStringWordNum(str)
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        -- local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount
        count = count + 1
    end
    return count
end

function TextAnim:seek(time)

    if self.first == true then
        self.ori_str = self.text.str

        math.randomseed(114514)
        self.lastTime = self.progress
        self:initAnimConfig()

        if Amaz.Macros and Amaz.Macros.EditorSDK then
            self.wordGap = 0.0
        else
        end
	    self.text.renderToRT = self.renderToRT
        if self.renderToRT then
            self:setMatToSDFText()
        end
        self.first = false
        local fs = self.rich_text.letters:get(0).letterStyle.fontSize
        -- Amaz.LOGI("lrc first", fs)
        -- if self.ori_fs == nil then
            self.ori_fs = fs
        -- end

        -- local Deep_GlowRootLua = self.text.entity.scene:findEntityBy("Deep_Glow_Root"):getComponent("ScriptComponent")
        -- self.LuaObj1 = Amaz.ScriptUtils.getLuaObj(Deep_GlowRootLua:getScript())
        -- local GaussianBlurRootL1ua = self.text.entity.scene:findEntityBy("Gaussian_Blur_Root_1"):getComponent("ScriptComponent")
        -- self.LuaObj2 = Amaz.ScriptUtils.getLuaObj(GaussianBlurRootL1ua:getScript())

    else
    end

    if isEditor then
        if self.autoPlay then
            -- Amaz.LOGI("lrc time", time)
            self.progress = time % self.duration / self.duration
        end
    else
        self.progress = time % (self.duration+0.00001) / (self.duration+0.00001)
        if self.progress > 1 then
            self.progress = 1
        end
    end

    local use_fs = self.ori_fs < 30 and 30 or self.ori_fs
    -- Amaz.LOGI("lrc use_fs", tostring(use_fs))

    local letter_vector = Amaz.Vector()
    for i = 1, self.rich_text.letters:size() do
        local letter = self.rich_text.letters:get(i-1)
        local lsc = letter.letterStyle:clone()
        lsc.fontSize = use_fs
        letter.letterStyle = lsc
        letter_vector:pushBack(letter)
    end
    self.rich_text.letters = letter_vector
    if self.rich_text.forceFlushCommandQueue then
        self.rich_text:forceFlushCommandQueue()
    end

    self.trans_scale = self.ori_fs/use_fs
    local s = self.trans_scale
    self.trans.localScale = Amaz.Vector3f(s,s,s)

    self:updateAnim(self.progress)

    local u_TextFontSize = self:getTextFontSize() / 26 * self.parentTrans.localScale.x
    local textColor = self:getTextColor()
    local expandSize = self.text:getRectExpanded()
    self.material:setFloat("u_TextFontSize", u_TextFontSize)
    self.material:setVec2("expandSize", Amaz.Vector2f(expandSize.width, expandSize.height))
    self.material:setVec4("u_TextColor", Amaz.Vector4f(textColor.x, textColor.y, textColor.z, 1.0))

end

function TextAnim:getTextAlpha(rich_text, index)
    local text = rich_text
    local alpha = 1.0
    if text then --
        if text.forceFlushCommandQueue then
            text:forceFlushCommandQueue()
        end
        local letters = text.letters
        if letters:size() > index then
            local letter0 = letters:get(index)
            alpha = letter0 and letter0.letterStyle and letter0.letterStyle.letterAlpha or 1.
        end

    else
        alpha = self.text.textColor.w

    end
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        alpha = 1.0
    end
    return alpha
end

function TextAnim:updateAnim(_p)
    local p = _p

    -- p = math.floor(p*34)/34

    local s0 = self.attrs:GetVal("ADBE_Scale_0_1", p)[1]
    s0 = s0 * 0.01
    -- Amaz.LOGI("lrc p "..p*34, s0)
    self.material:setFloat("s0", s0)

    local blur = self.attrs:GetVal("ADBE_Gaussian_Blur_2_0001_0_0", p)[1]
    self.material:setFloat("u_Strength", blur*0.0002)

    local user_alpha = self.text.alpha * self.rich_text.globalAlpha * self:getTextAlpha(self.rich_text, 0)
    self.material:setFloat("user_alpha", user_alpha)

    for i = 1, 13 do
        local pp = util.remap01((4+i)/34, (21+i)/34, p)
        local ss = util.bezier({0.166666667, 0.166666667, 0.48, 1,})(pp, 0, 1, 1)
        ss = util.mix(0.5, 1, ss)
        self.material:setFloat("s"..i, ss)

        -- Amaz.LOGI("lrc ss "..i, tostring(ss))

        local aa = 0
        if p < (4+i)/34 then
            aa = 0
        else
            local ep = ss>0.99 and 0 or 1
            local ap = util.remap01((4+i)/34, (10+i)/34, p)
            ap = util.mix(0.25, 1, ap)
            -- aa = ap * util.mix(1, 0, util.remap01(0.9,1, pp))
            aa = ap * ep
        end
        self.material:setFloat("a"..i, aa*user_alpha)
    end


end

function TextAnim:onEnter()
	self.first = true
	
end
function TextAnim:resetData( ... )
	if self.text ~= nil then

        -- self.text.str = self.ori_str
        if self.rich_text.forceFlushCommandQueue then
            self.rich_text:forceFlushCommandQueue()
        end
        self.text:forceTypeSetting()
        if self.rich_text.forceFlushCommandQueue then
            self.rich_text:forceFlushCommandQueue()
        end

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
        self.text.renderToRT = false
        self.text.chars = chars
	end

    local fs = self.rich_text.letters:get(0).letterStyle.fontSize
    if fs ~= 30 then
    else
        fs = self.ori_fs
    end
    -- Amaz.LOGI("lrc resetdata fontsize", fs)

    local letter_vector = Amaz.Vector()
    for i = 1, self.rich_text.letters:size() do
        local l = self.rich_text.letters:get(i-1)
        local lsc = l.letterStyle:clone()
        lsc.fontSize = fs
        l.letterStyle = lsc
        letter_vector:pushBack(l)
    end
    self.rich_text.letters = letter_vector

    if self.rich_text.forceFlushCommandQueue then
        self.rich_text:forceFlushCommandQueue()
    end
    self.text:forceTypeSetting()
    if self.rich_text.forceFlushCommandQueue then
        self.rich_text:forceFlushCommandQueue()
    end


	self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
	self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
	self.trans.localScale = Amaz.Vector3f(1, 1, 1)
    self.text.targetRTExtraSize = Amaz.Vector2f(0.0, 0.0)

    self.trans_scale = 1

    -- if self.customEntity ~= nil then
    --     self.text.entity.scene:removeEntity(self.customEntity)
    --     self.camera.children:erase(self.customEntity)
    --     self.customEntity = nil
    -- end
    -- self.text.entity.layer = 0
end

function TextAnim:setDuration(duration)
   self.duration = duration
end
function TextAnim:onLeave()
    self:resetData()
	self.first = true
end
function TextAnim:clear()

	self:resetData()
end

exports.TextAnim = TextAnim
return exports
