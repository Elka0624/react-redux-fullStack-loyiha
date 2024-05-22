---@class T1608802625400681067 : ScriptComponent
----@field curTime number [UI(Range={0, 3}, Slider)]
----@field duration number [UI(Input)]
local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3 * xc1 * (1 - t) * (1 - t) * t + 3 * xc2 * (1 - t) * t * t + t * t * t
    ret[2] = 3 * yc1 * (1 - t) * (1 - t) * t + 3 * yc2 * (1 - t) * t * t + t * t * t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3 * xc1 * (1 - t) * (1 - 3 * t) + 3 * xc2 * (2 - 3 * t) * t + 3 * t * t
    ret[2] = 3 * yc1 * (1 - t) * (1 - 3 * t) + 3 * yc2 * (2 - 3 * t) * t + 3 * t * t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts + te) / 2
        local value = getBezierValue(controls, tm)
        if (value[1] > x) then
            te = tm
        else
            ts = tm
        end
    until (te - ts < 0.0001)

    return (te + ts) / 2
end

local function bezier(controls)
    return function(t, b, c, d)
        t = t / d
        local tvalue = getBezierTfromX(controls, t)
        local value = getBezierValue(controls, tvalue)
        return b + c * value[2]
    end
end

local function funcEaseBlurAction1(t, b, c, d)
    t = t / d
    -- diyijieduandeweiyiquxian，beisaierquxianbanben
    local controls = {.05, .71, .61, .99}
    local tvalue = getBezierTfromX(controls, t)
    local deriva = getBezierDerivative(controls, tvalue)
    return math.abs(deriva[2] / deriva[1]) * c
end

local function funcEaseAction3(t, b, c, d)
    t = t / d
    -- diyijieduandeweiyiquxian，zhegeshigongshibanben
    if t ~= 0.0 and t ~= 1.0 then
        t = math.exp(-7.0 * t) * 1.0 * math.sin((t - 0.075) * (2.0 * math.pi) / 0.3) + 1.0
    end
    return Amaz.Ease.linearFunc(t, c, b)
end

local function funcEaseBlurAction3(t, b, c, d)
    t = t / d
    -- diyijieduandemohuquxian，zhegeshigongshibanben
    t =
        math.abs(
        math.pow(2, -5.0 * t) * math.log(2) * math.sin(2.5 * math.pi * t - 0.5 * math.pi) +
            math.pow(2, -5.0 * t) * math.cos(2.5 * math.pi * t - 0.5 * math.pi)
    )

    return c * t
end

local function clamp(min, max, value)
    return math.min(math.max(value, 0), 1)
end

local function saturate(value)
    return clamp(0, 1, value)
end

local function lerp(a, b, c)
    c = saturate(0, 1, c)
    return (1 - c) * a + c * b
end

local function lerpVector3(a, b, c)
    c = saturate(0, 1, c)
    return Amaz.Vector3f(lerp(a.x, b.x, c), lerp(a.y, b.y, c), lerp(a.z, b.z, c))
end

local function remap(smin, smax, dmin, dmax, value)
    return (value - smin) / (smax - smin) * (dmax - dmin) + dmin
end

local function remapClamped(smin, smax, dmin, dmax, value)
    return saturate(value - smin) / (smax - smin) * (dmax - dmin) + dmin
end

local function remapVector3(smin, smax, dmin, dmax, value)
    return Amaz.Vector3f(
        remap(smin.x, smax.x, dmin.x, dmax.x, value.x),
        remap(smin.y, smax.y, dmin.y, dmax.y, value.y),
        remap(smin.z, smax.z, dmin.z, dmax.z, value.z)
    )
end

local function remapVector4(smin, smax, dmin, dmax, value)
    return Amaz.Vector3f(
        remap(smin.x, smax.x, dmin.x, dmax.x, value.x),
        remap(smin.y, smax.y, dmin.y, dmax.y, value.y),
        remap(smin.z, smax.z, dmin.z, dmax.z, value.z),
        remap(smin.w, smax.w, dmin.w, dmax.w, value.w)
    )
end

local function playAnimation(info, nt, setValue)
    for key, value in pairs(info.default) do
        setValue(key, value)
    end
    for key, value in pairs(info.animations) do
        for index, keyframe in pairs(value) do
            if nt >= keyframe[1] and nt <= keyframe[2] then
                local func
                if type(keyframe[5]) == "function" then
                    func = keyframe[5]
                elseif type(keyframe[5]) == "table" and #keyframe[5] == 4 then
                    func = bezier(keyframe[5])
                end
                if type(func) == "function" then
                    local t = nt - keyframe[1]
                    if keyframe[6] then
                        t = 1 - t
                    end
                    if type(keyframe[3]) == "number" and type(keyframe[4]) == "number" then
                        setValue(key, func(t, keyframe[3], keyframe[4] - keyframe[3], keyframe[2] - keyframe[1]))
                    elseif
                        type(keyframe[3]) == "table" and type(keyframe[4]) == "table" and #keyframe[3] == #keyframe[4]
                     then
                        local values = {}
                        for i = 1, #keyframe[3] do
                            values[i] =
                                func(t, keyframe[3][i], keyframe[4][i] - keyframe[3][i], keyframe[2] - keyframe[1])
                        end
                        setValue(key, values)
                    end
                end
                break
            -- elseif nt < keyframe[1] then
            -- 	if index > 1 then
            -- 		local val = value[index - 1][4]
            -- 		if value[index - 1][6] then val = value[index - 1][3] end
            -- 		setValue(key, val)
            -- 	end
            -- 	break
            -- elseif nt > keyframe[2] then
            -- 	local val = value[index][4]
            -- 	if keyframe[6] then val = value[index][3] end
            -- 	setValue(key, val)
            end
        end
    end
end

local function anchor(pivot, anchor, halfWidth, halfHeight, translate, rotate, scale)
    local anchor =
        Amaz.Vector4f(
        remap(-.5, .5, 1, -1, pivot[1]) * halfWidth + remap(-.5, .5, -(1 - scale.x), 1 - scale.x, anchor[1]) * halfWidth,
        remap(-.5, .5, 1, -1, pivot[2]) * halfHeight +
            remap(-.5, .5, -(1 - scale.y), 1 - scale.y, anchor[2]) * halfHeight,
        0,
        1
    )
    local mat = Amaz.Matrix4x4f()
    mat:setTRS(
        Amaz.Vector3f(remap(-.5, .5, -1, 1, pivot[1]) * halfWidth, remap(-.5, .5, -1, 1, pivot[2]) * halfHeight, 0),
        Amaz.Quaternionf.eulerToQuaternion(
            Amaz.Vector3f(rotate.x / 180 * math.pi, rotate.y / 180 * math.pi, rotate.z / 180 * math.pi)
        ),
        Amaz.Vector3f(1, 1, 1)
    )
    anchor = mat:multiplyVector4(anchor)
    return Amaz.Vector3f(anchor.x, anchor.y, anchor.z) + translate, rotate, scale
end

local exports = exports or {}
local T1608802625400681067 = T1608802625400681067 or {}
T1608802625400681067.__index = T1608802625400681067
function T1608802625400681067.new(construct, ...)
    local self = setmetatable({}, T1608802625400681067)
    self.duration = 1.0
    self.curTime = 0
    self.count = 0
    self.anims = {}
    self.values = {}
    self.params = {}
    self.animDirty = true
    if construct and T1608802625400681067.constructor then
        T1608802625400681067.constructor(self, ...)
    end
    return self
end

function T1608802625400681067:constructor()
end

local renderChain = {
    {
        name = "pass1",
        input = {},
        shader_vs_path = "shader/pass1/vs.lua",
        shader_fs_path = "shader/pass1/fs.lua",
        blendEnable = false
    },
    {
        name = "pass2",
        input = {
            pass2_inputTex_0 = "pass1"
        },
        shader_vs_path = "shader/pass2/vs.lua",
        shader_fs_path = "shader/pass2/fs.lua",
        blendEnable = false
    },
    {
        name = "pass3",
        input = {
            pass3_inputTex_0 = "pass2",
            noiseTex = "pass1"
        },
        shader_vs_path = "shader/pass3/vs.lua",
        shader_fs_path = "shader/pass3/fs.lua",
        blendEnable = false
    },
    {
        name = "pass4",
        input = {
            pass4_inputTex_0 = "pass3"
        },
        shader_vs_path = "shader/pass4/vs.lua",
        shader_fs_path = "shader/pass4/fs.lua",
        blendEnable = true
    }
    -- {
    --     name = "pass5",
    --     input = {
    --         pass5_inputTex_0 = "pass4",
    --     },
    --     shader_vs_path = "shader/pass5/vs.lua",
    --     shader_fs_path = "shader/pass5/fs.lua",
    -- 	blendEnable = false
    -- },
    -- {
    --     name = "pass6",
    --     input = {
    --         pass6_inputTex_0 = "pass5",
    -- 		pass6_inputTex_1 = "pass4"
    --     },
    --     shader_vs_path = "shader/pass6/vs.lua",
    --     shader_fs_path = "shader/pass6/fs.lua",
    -- 	blendEnable = true
    -- }
}

function T1608802625400681067:onStart(comp)
    --self.text = comp.entity:getComponent("SDFText")
    self.entity = comp.entity
    self.text = comp.entity:getComponent("SDFText")
    if self.text == nil then
        local text = comp.entity:getComponent("Text")
        if text ~= nil then
            self.text = comp.entity:addComponent("SDFText")
            self.text:setTextWrapper(text)
        end
    end
    self.trans = comp.entity:getComponent("Transform")
    -- self.text.str = 'Transform'
    self.first = true
    self.renderer = nil
    if self.text ~= nil then
        self.renderer = comp.entity:getComponent("MeshRenderer")
    else
        self.renderer = comp.entity:getComponent("Sprite2DRenderer")
    end
    local path = comp.entity.scene.assetMgr.rootDir
    for i = 1, #renderChain do
        renderChain[i].shader_vs = includeRelativePath(renderChain[i].shader_vs_path)
        renderChain[i].shader_fs = includeRelativePath(renderChain[i].shader_fs_path)
    end
    local Utils = includeRelativePath("Utils.lua")
    Utils.buildRenderChain(comp, renderChain, self.sharedMaterial)
    self.animDirty = true
end

if Amaz.Macros and Amaz.Macros.EditorSDK then
    ---@function [UI(Button="Auto Play")]
    ---@return void
    function T1608802625400681067:ButtonClip()
        if self.isAutoPlay then
            self.isAutoPlay = false
        else
            self.curTime = 0
            self.isAutoPlay = true
        end
    end

    function T1608802625400681067:onUpdate(comp, deltaTime)
        if self.isAutoPlay then
            self.curTime = self.curTime + deltaTime
            self.curTime = self.curTime % 3.0
        end
        self:seek(self.curTime)
    end
end

function T1608802625400681067:animate()
    return {
        -- ['playSpeed'] = 30,
        ["anchor"] = {0, 0},
        ["pivot"] = {0, 0},
        ["default"] = {
            ["blurType"] = 1,
            ["blurDirection"] = {1, 0},
            ["blurStep"] = 0,
            ["translate"] = {0, 0, 0},
            ["rotate"] = {0, 0, 0},
            ["scale"] = {1, 1, 1},
            ["alpha"] = 1
        },
        ["animations"] = {
            -- 0 none 1 motion 2 scale
            ["blurType"] = {},
            ["blurDirection"] = {},
            ["blurStep"] = {},
            ["translate_1"] = {
                {0.6, 0.7, {-1.2, 0.7, 0}, {-1.2, 0.7, 0}, {0, 1, 0, 1}}
            },
            ["translate_2"] = {
                {0.7, 0.8, {-1.2, 0.7, 0}, {-1.2, 0.7, 0}, {0, 1, 0, 1}}
            },
            ["rotate"] = {},
            --{startTime,endTime,startValue,endValue,BezierParams}
            ["scale_1"] = {
                {0.5, 0.6, {2, 2, 2}, {2, 2, 2}, {0, 1, 0, 1}}
            },
            ["scale_2"] = {
                {0.6, 0.7, {1, 1, 1}, {1, 1, 1}, {0, 1, 0, 1}}
            },
            ["scale_3"] = {
                {0.7, 0.8, {2, 2, 2}, {2, 2, 2}, {0, 1, 0, 1}}
            },
            ["iTime"] = {
                {0, 0.1, 0, 1, {0, 0, 1, 1}}
            }
        }
    }
end
-- startTime endTime startValue endValue easeFunction
-- mode: 0 same duration per char, 1 not same duration per char
-- duration: ratio of char animation and total time, only enable when mode is 0
function T1608802625400681067:animateChar(char)
    return {
        ["mode"] = 0,
        ["duration"] = .8,
        ["anchor"] = {0, 0},
        ["pivot"] = {0, 0},
        ["default"] = {
            ["translate"] = {0, 0, 0},
            -- ['translate.x'] = 0,
            -- ['translate.y'] = 0,
            -- ['translate.z'] = 0,
            ["rotate"] = {0, 0, 0},
            -- ['rotate.x'] = 0,
            -- ['rotate.y'] = 0,
            -- ['rotate.z'] = 0,
            ["scale"] = {1, 1, 1},
            -- ['scale.x'] = 0,
            -- ['scale.y'] = 0,
            -- ['scale.z'] = 0,
            ["color"] = {1, 1, 1, 1}
            -- ['color.x'] = 1,
            -- ['color.y'] = 1,
            -- ['color.z'] = 1,
            -- ['color.w'] = 1,
        },
        ["animations"] = {
            ["translate"] = {},
            ["translate.x"] = {},
            ["translate.y"] = {},
            ["translate.z"] = {},
            ["rotate"] = {},
            ["rotate.x"] = {},
            ["rotate.y"] = {},
            ["rotate.z"] = {},
            ["scale"] = {},
            ["scale.x"] = {},
            ["scale.y"] = {},
            ["scale.z"] = {},
            ["color"] = {},
            ["color.x"] = {},
            ["color.y"] = {},
            ["color.z"] = {},
            ["color.w"] = {}
        }
    }
end

function T1608802625400681067:updateAnim()
    if not self.animDirty then
        return
    end
    self.animDirty = false
    local material = self.materials:get(0)
    -- time【0-1】

    local width = Amaz.BuiltinObject:getOutputTextureWidth()
    local height = Amaz.BuiltinObject:getOutputTextureHeight()
    self.params = {
        -- zidingyishuxingdonghuapeizhi
        -- xiamianliziyongyuchuanrusuishijianbianhuaerbianhuadeuniformdaoshader
        {
            -- shijian，buxuyaoxiugai
            key = "_time",
            obj = self.values,
            startValue = 0.0, -- qishizhi
            endValue = 1.0, -- jieshuzhi
            defaultValue = 0.0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setFloat(key, value)
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.0, -- qishishijian
            endTime = 0.15 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "glitchSize",
            obj = self.values,
            startValue = 0.0, -- qishizhi
            endValue = 0.6, -- jieshuzhi
            defaultValue = 0.0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setFloat(key, value)
            end,
            curve = Amaz.Ease.linear,
            startTime = 0.0, -- qishishijian
            endTime = 0.2 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "glitchSize",
            obj = self.values,
            startValue = 0.6, -- qishizhi
            endValue = 0.0, -- jieshuzhi
            defaultValue = 0.0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setFloat(key, value)
            end,
            curve = Amaz.Ease.linear,
            startTime = 0.2, -- qishishijian
            endTime = 0.3 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(0, 0, 0), -- qishizhi
            endValue = Amaz.Vector3f(0.8, 0, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.0, -- qishishijian
            endTime = 0.1 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "flag",
            obj = self.values,
            startValue = 0, -- qishizhi
            endValue = 1, -- jieshuzhi
            defaultValue = 0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setInt(key, value)
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.1, -- qishishijian
            endTime = 0.15 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(0, 0, 0), -- qishizhi
            endValue = Amaz.Vector3f(-0.2, 0, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.1, -- qishishijian
            endTime = 0.15 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(0, 0, 0), -- qishizhi
            endValue = Amaz.Vector3f(0.4, 0, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.15, -- qishishijian
            endTime = 0.2 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "flag",
            obj = self.values,
            startValue = 0, -- qishizhi
            endValue = 2, -- jieshuzhi
            defaultValue = 0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setInt(key, value)
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.15, -- qishishijian
            endTime = 0.2 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(-0.1, 0.02, 0), -- qishizhi
            endValue = Amaz.Vector3f(0, 0, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.2, -- qishishijian
            endTime = 0.3 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "flag",
            obj = self.values,
            startValue = 3, -- qishizhi
            endValue = 11, -- jieshuzhi
            defaultValue = 0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setInt(key, math.floor(value + 0.01))
            end,
            curve = function(t, b, c, d)
                t = t / d
                -- if t > 0 then
                return math.floor(b + c * t)
                -- else
                -- return b
                -- end
            end,
            startTime = 0.2, -- qishishijian
            endTime = 0.3 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localScale",
            obj = self.values,
            startValue = Amaz.Vector3f(1, 1, 1), -- qishizhi
            endValue = Amaz.Vector3f(2, 2, 2), -- jieshuzhi
            defaultValue = Amaz.Vector3f(1, 1, 1), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                self.trans.localScale = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.3, -- qishishijian
            endTime = 0.4 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "glitchSize",
            obj = self.values,
            startValue = 0.0, -- qishizhi
            endValue = 0.5, -- jieshuzhi
            defaultValue = 0.0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setFloat(key, value)
            end,
            curve = Amaz.Ease.linear,
            startTime = 0.3, -- qishishijian
            endTime = 0.35 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "glitchSize",
            obj = self.values,
            startValue = 0.5, -- qishizhi
            endValue = 0.0, -- jieshuzhi
            defaultValue = 0.0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setFloat(key, value)
            end,
            curve = Amaz.Ease.linear,
            startTime = 0.35, -- qishishijian
            endTime = 0.4 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "flag",
            obj = self.values,
            startValue = 3, -- qishizhi
            endValue = 11, -- jieshuzhi
            defaultValue = 0, -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                material:setInt(key, math.floor(value + 0.01))
            end,
            curve = function(t, b, c, d)
                t = t / d
                -- if t > 0 then
                return math.floor(b + c * t)
                -- else
                -- return b
                -- end
            end,
            startTime = 0.3, -- qishishijian
            endTime = 0.7 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localScale",
            obj = self.values,
            startValue = Amaz.Vector3f(2, 2, 2), -- qishizhi
            endValue = Amaz.Vector3f(1.3, 1.3, 1.3), -- jieshuzhi
            defaultValue = Amaz.Vector3f(1, 1, 1), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                self.trans.localScale = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.4, -- qishishijian
            endTime = 0.5 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(0, 0, 0), -- qishizhi
            endValue = Amaz.Vector3f(-1.3, 0.7, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.4, -- qishishijian
            endTime = 0.5 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localScale",
            obj = self.values,
            startValue = Amaz.Vector3f(1, 1, 1), -- qishizhi
            endValue = Amaz.Vector3f(2, 2, 2), -- jieshuzhi
            defaultValue = Amaz.Vector3f(1, 1, 1), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                self.trans.localScale = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.5, -- qishishijian
            endTime = 0.6 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(-1.3, 0.7, 0), -- qishizhi
            endValue = Amaz.Vector3f(1.3, -0.4, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.5, -- qishishijian
            endTime = 0.6 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(1.3, -0.4, 0), -- qishizhi
            endValue = Amaz.Vector3f(-0.05, -0.1, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.6, -- qishishijian
            endTime = 0.7 -- jieshushijian
        },
        {
            -- shijian，buxuyaoxiugai
            key = "localPosition",
            obj = self.values,
            startValue = Amaz.Vector3f(-0.05, -0.1, 0), -- qishizhi
            endValue = Amaz.Vector3f(0.0, -0.1, 0), -- jieshuzhi
            defaultValue = Amaz.Vector3f(0, 0, 0), -- morenzhi，gaijieduanmeiyouzhixing，huozhezhixingwanchengzhihougaiyingyongdezhi
            actionHandle = function(key, value) -- seekshidehuidiaofangfa
                -- material:setFloat(key, value)
                -- value.x = value.x - userT.x
                -- value.y = value.y - userT.y
                value.x = value.x / self.userS.x * width / height * 0.5
                value.y = value.y / self.userS.y
                self.trans.localPosition = value
            end,
            curve = function(t, b, c, d)
                t = t / d
                local controls = {0, 1, 0, 1} -- beisaierquxiancanshu

                local tvalue = getBezierTfromX(controls, t)
                local value = getBezierValue(controls, tvalue)
                return b + c * value[2]
            end,
            startTime = 0.7, -- qishishijian
            endTime = 0.8 -- jieshushijian
        }
    }

    for i = 1, #self.params do
        local param = self.params[i]
        self.anims[i] =
            self.entity.scene.tween:fromTo(
            param.obj,
            {[param.key] = param.startValue},
            {[param.key] = param.endValue},
            param.endTime - param.startTime,
            param.curve,
            nil,
            0.0,
            nil,
            false
        )
    end
end

function T1608802625400681067:seek(time)
    if self.first then
        local materials = Amaz.Vector()
        materials:pushBack(self.sharedMaterial)
        self.renderer.sharedMaterials = materials
        self.materials = self.renderer.materials
        if self.text ~= nil then
            self.text.renderToRT = true
        else
        end
        self.first = false
    else
        self.renderer.materials = self.materials
    end

    local progress = (time % self.duration) / self.duration
    self:updateAnim()

    self.userS = Amaz.Vector3f(1, 1, 1)
    -- local userR = parentTrans.localOrientation
    self.userT = Amaz.Vector3f(0, 0, 0)
    self.animS = Amaz.Vector3f(1, 1, 1)
    -- local animR = animTrans.localOrientation
    self.animT = Amaz.Vector3f(0, 0, 0)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
    else
        local animTrans = self.entity:getComponent("Transform")
        local parentTrans = animTrans.parent
        self.userS = parentTrans.localScale
        -- userR = parentTrans.localOrientation
        self.userT = parentTrans.localPosition
        self.animS = animTrans.localScale
        -- animR = animTrans.localOrientation
        self.animT = animTrans.localPosition
    end

    self.materials:get(0):setFloat("userSX", self.userS.x)

    -- seekzhiqianxianjiangzidingyishuxingdezhishezhichengmorenzhi，buranhuicanliushangyiciseekdezhi
    for i = 1, #self.anims do
        local param = self.params[i]
        if param.actionHandle ~= nil then
            param.actionHandle(param.key, param.defaultValue)
        end
    end

    for i = 1, #self.anims do
        local param = self.params[i]
        if progress >= param.startTime and progress <= param.endTime then
            self.anims[i]:set(progress - param.startTime)
            if param.actionHandle ~= nil then
                param.actionHandle(param.key, self.values[param.key])
            end
        -- elseif progress < param.startTime then
        --     self.anims[i]:set(0)
        -- 	if param.actionHandle ~= nil then
        --         param.actionHandle(param.key, self.values[param.key])
        --     end
        -- elseif progress > param.endTime then
        --     self.anims[i]:set(1)
        -- 	if param.actionHandle ~= nil then
        --         param.actionHandle(param.key, self.values[param.key])
        --     end
        end
    end

    -- -- text animation
    -- if self.text ~= nil then
    -- 	self.count = self.text.chars:size()

    -- 	for i = 1, self.count do
    -- 		local char = self.text.chars:get(i - 1)
    -- 		local info = self:animateChar(char)
    -- 		local nt = 0
    -- 		if info.mode == 0 then
    -- 			local late = 0
    -- 			if self.count > 1 then
    -- 				late = (1 - info.duration) / (self.count - 1) * (i - 1)
    -- 			end
    -- 			if time / self.duration >= late then
    -- 				nt = saturate((time / self.duration - late) / info.duration)
    -- 			end
    -- 		else
    -- 			local duration = Amaz.Ease.linear((self.count - i + 1) / self.count, 0, self.duration, 1)
    -- 			nt = (time - (self.duration - duration)) / duration
    -- 		end

    -- 		local translate = Amaz.Vector3f()
    -- 		local rotate = Amaz.Vector3f()
    -- 		local scale = Amaz.Vector3f()
    -- 		local color = Amaz.Vector4f()
    -- 		playAnimation(info, nt, function (key, value)
    -- 			if key == 'translate.x' then
    -- 				translate.x = value
    -- 			elseif key == 'translate.y' then
    -- 				translate.y = value
    -- 			elseif key == 'translate.z' then
    -- 				translate.z = value
    -- 			elseif key == 'translate' and type(value) == 'table' then
    -- 				translate:set(value[1], value[2], value[3])
    -- 			elseif key == 'rotate.x' then
    -- 				rotate.x = value
    -- 			elseif key == 'rotate.y' then
    -- 				rotate.y = value
    -- 			elseif key == 'rotate.z' then
    -- 				rotate.z = value
    -- 			elseif key == 'rotate' and type(value) == 'table' then
    -- 				rotate:set(value[1], value[2], value[3])
    -- 			elseif key == 'scale.x' then
    -- 				scale.x = value
    -- 			elseif key == 'scale.y' then
    -- 				scale.y = value
    -- 			elseif key == 'scale.z' then
    -- 				scale.z = value
    -- 			elseif key == 'scale' and type(value) == 'table' then
    -- 				scale:set(value[1], value[2], value[3])
    -- 			elseif key == 'color.x' then
    -- 				color.x = value
    -- 			elseif key == 'color.y' then
    -- 				color.y = value
    -- 			elseif key == 'color.z' then
    -- 				color.z = value
    -- 			elseif key == 'color.w' then
    -- 				color.w = value
    -- 			elseif key == 'color' and type(value) == 'table' then
    -- 				color:set(value[1], value[2], value[3], value[4])
    -- 			end
    -- 		end)

    -- 		translate, rotate, scale = anchor(info['pivot'], info['anchor'], char.width / 3, char.height / 3, translate, rotate, scale)
    -- 		char.position = char.initialPosition + translate
    -- 		char.rotate = rotate
    -- 		char.scale = scale
    -- 		char.color = color
    -- 	end

    -- 	local chars = self.text.chars
    -- 	self.text.chars= chars
    -- end

    -- local info = self:animate()
    -- local translate = Amaz.Vector3f()
    -- local rotate = Amaz.Vector3f()
    -- local scale = Amaz.Vector3f()
    -- -- local realTime = time - time % (1 / info.playSpeed)
    -- playAnimation(info, time / self.duration, function (key, value)
    -- 	if string.find(key,'translate') and type(value) == 'table' then
    -- 		translate:set(value[1], value[2], value[3])
    -- 	elseif key == 'rotate' and type(value) == 'table' then
    -- 		rotate:set(value[1], value[2], value[3])
    -- 	elseif string.find(key,'scale') and type(value) == 'table' then
    -- 		scale:set(value[1], value[2], value[3])
    -- 		Amaz.LOGE("wjs",key)
    -- 	elseif key == 'blurType' then
    --         self.materials:get(0):enableMacro('BLUR_TYPE', value)
    --     elseif key == 'blurDirection' then
    --         self.materials:get(0):setVec2('blurDirection', Amaz.Vector2f(value[1], value[2]))
    --     elseif key == 'blurStep' then
    -- 		self.materials:get(0):setFloat('blurStep', value)
    -- 	elseif key == 'iTime' then
    --         self.materials:get(0):setFloat('iTime', value)
    -- 	end
    -- end)

    local translate = self.trans.localPosition
    local rotate = self.trans.localEulerAngle
    local scale = self.trans.localScale

    local halfOutputHeight = Amaz.BuiltinObject:getOutputTextureHeight() / 2
    local halfWidth = 0
    local halfHeight = 0
    if self.text ~= nil then
        halfWidth = (self.text.rect.width - self.text.rect.x) / 2 / halfOutputHeight
        halfHeight = (self.text.rect.height - self.text.rect.y) / 2 / halfOutputHeight
    else
        local size = self.renderer:getTextureSize()
        halfWidth = size.x / 2 / halfOutputHeight
        halfHeight = size.y / 2 / halfOutputHeight
    end
    translate, rotate, scale = anchor({0, 0}, {0, 0}, halfWidth, halfHeight, translate, rotate, scale)

    -- self.materials:get(0):setFloat("u_OutputWidth", Amaz.BuiltinObject:getOutputTextureWidth())
    -- self.materials:get(0):setFloat("u_OutputHeight", Amaz.BuiltinObject:getOutputTextureHeight())

    self.trans.localPosition = translate
    self.trans.localEulerAngle = rotate
    self.trans.localScale = scale

    -- time=math.floor(time*16)/4
    -- local t = time / self.duration
    -- t=(t-0.1)/0.9
    -- if t>0 then
    -- 	t=t*1.1
    -- end
    -- if t>1 then
    -- 	t=1
    -- end
    self.materials:get(0):setFloat("firstend", 0.7)
    -- self.materials:get(0):setFloat("_time",0.1)

    local mat = self.materials:get(0)
    local tex = mat:getTex("_MainTex")
    if tex then
        mat:setVec4("texSize", Amaz.Vector4f(tex.width, tex.height, 0, 0))
    end
end

function T1608802625400681067:setDuration(duration)
    self.animDirty = true
    self.duration = duration
end

function T1608802625400681067:clear()
    if self.text ~= nil and not self.clearState then
        local chars = self.text.chars
        for i = 1, chars:size() do
            local char = chars:get(i - 1)
            if char.rowth ~= -1 then
                char.position = char.initialPosition
                char.rotate = Amaz.Vector3f(0, 0, 0)
                char.scale = Amaz.Vector3f(1, 1, 1)
                char.color = Amaz.Vector4f(1, 1, 1, 1)
            end
        end
        self.animDirty = true
        self.text.chars = chars
        self.text.renderToRT = false
        self.clearState = true
        -- self.renderer.sharedMaterials = Amaz.Vector()
    end

    self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
    self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
    self.trans.localScale = Amaz.Vector3f(1, 1, 1)
end

function T1608802625400681067:onEnter()
    self.first = true
    self.animDirty = true
    self.clearState = false
    -- self.text.renderToRT = true
end

function T1608802625400681067:onLeave()
    if self.text ~= nil and not self.clearState then
        self:clear()
    end
    self.animDirty = true
    self.first = true
end

exports.T1608802625400681067 = T1608802625400681067
return exports
